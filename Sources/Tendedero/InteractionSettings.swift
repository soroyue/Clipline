import AppKit
import SwiftUI

enum InteractionTiming {
    static func value(_ key: String, fallback: Double, range: ClosedRange<Double>, defaults: UserDefaults = .standard) -> Double {
        guard defaults.object(forKey: key) != nil else { return fallback }
        let n = defaults.double(forKey: key)
        return n.isFinite ? min(range.upperBound, max(range.lowerBound, n)) : fallback
    }
    static var reveal: Double { value("revealSeconds", fallback: 0.5, range: 0.2...2) }
    static var hideTotal: Double { value("hideSeconds", fallback: 1.2, range: 0.4...4) }
    static var returnDuration: Double { value("returnSeconds", fallback: 1.4, range: 0.3...3) }
    static var peek: Double { value("peekSeconds", fallback: 2.5, range: 0.5...5) }
    static var hideDelay: Double { max(0, hideTotal - 0.22) }
    static var browseHideDelay: Double { max(hideDelay, 0.7 + returnDuration + 0.4) }
}

@MainActor
final class InteractionSettings {
    private var window: NSWindow?
    func show() {
        if window == nil {
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 470, height: 350),
                             styleMask: [.titled, .closable], backing: .buffered, defer: false)
            w.title = "Clipline — " + L("Interaction settings")
            w.isReleasedWhenClosed = false
            w.contentViewController = NSHostingController(rootView: InteractionSettingsBody())
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct InteractionSettingsBody: View {
    @AppStorage("revealSeconds") private var reveal = 0.5
    @AppStorage("hideSeconds") private var hide = 1.2
    @AppStorage("returnSeconds") private var returnDuration = 1.4
    @AppStorage("peekSeconds") private var peek = 2.5

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            timing(L("Top-edge dwell"), value: $reveal, range: 0.2...2)
            timing(L("Hide after leaving (including animation)"), value: $hide, range: 0.4...4)
            timing(L("Return animation after browsing"), value: $returnDuration, range: 0.3...3)
            timing(L("New-content preview hold"), value: $peek, range: 0.5...5)
            Text(L("Reading a preview keeps the line open. Browsing returns to the latest items before hiding."))
                .font(.caption).foregroundStyle(.secondary)
            Button(L("Restore defaults")) {
                reveal = 0.5; hide = 1.2; returnDuration = 1.4; peek = 2.5
            }
        }.padding(24).frame(width: 470)
    }

    private func timing(_ title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.1f s", value.wrappedValue)).monospacedDigit()
            }
            Slider(value: value, in: range, step: 0.1)
        }
    }
}
