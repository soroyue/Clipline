import AppKit
import SwiftUI

/// A real popover can extend below the narrow rope panel without clipping.
/// It stays open while the pointer is on the card OR inside its scroll view.
@MainActor
final class TextPreview {
    static let shared = TextPreview()
    private let popover = NSPopover()
    private weak var anchor: NSView?
    private var timer: Timer?
    private var awaySince: Date?
    var isShown: Bool { popover.isShown }

    func show(_ text: String, from view: NSView, copy: @escaping () -> Void) {
        close()
        guard view.window?.isVisible == true else { return }
        anchor = view
        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: TextPreviewBody(text: text) {
            copy()
            self.close()
        })
        popover.contentSize = NSSize(width: 420, height: 330)
        // macOS adjusts this position to stay on the current screen.
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.checkPointer() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func close(from view: NSView? = nil) {
        if let view, anchor !== view { return }
        timer?.invalidate()
        timer = nil
        awaySince = nil
        popover.close()
        anchor = nil
    }

    private func checkPointer() {
        guard let anchor, let window = anchor.window, window.isVisible, popover.isShown else {
            close(); return
        }
        let mouse = NSEvent.mouseLocation
        let card = window.convertToScreen(anchor.convert(anchor.bounds, to: nil))
        let preview = popover.contentViewController?.view.window?.frame ?? .zero
        if card.insetBy(dx: -8, dy: -8).contains(mouse) || preview.contains(mouse) {
            awaySince = nil
        } else if let since = awaySince {
            if Date().timeIntervalSince(since) > 0.35 { close() }
        } else { awaySince = Date() }
    }
}

private struct TextPreviewBody: View {
    let text: String
    let copy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(L("Text preview"), systemImage: "doc.text")
                    .font(.headline)
                Spacer()
                Button(action: copy) { Label(L("Copy"), systemImage: "doc.on.doc") }
            }
            Divider()
            ScrollView {
                Text(text)
                    .font(.system(size: 13))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text("\(text.count) " + L("characters"))
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 420, height: 330)
    }
}
