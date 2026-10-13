import AppKit
import SwiftUI

@MainActor
final class TextHistory {
    private var window: NSWindow?

    func show(line: Line) {
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 500),
                                  styleMask: [.titled, .closable, .miniaturizable, .resizable],
                                  backing: .buffered, defer: false)
            window.title = "Clipline — " + L("Text history")
            window.isReleasedWhenClosed = false
            window.contentViewController = NSHostingController(rootView: TextHistoryBody(line: line))
            window.minSize = NSSize(width: 620, height: 360)
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

private struct TextHistoryBody: View {
    @ObservedObject var line: Line
    @State private var query = ""
    @State private var selected: UUID?

    private var results: [Pegged] {
        line.items.reversed().filter {
            !$0.falling && $0.isText && (query.isEmpty || $0.text!.localizedCaseInsensitiveContains(query))
        }
    }

    private var current: Pegged? { results.first { $0.id == selected } }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField(L("Search text history"), text: $query)
                    .textFieldStyle(.roundedBorder)
                Text("\(results.count)").foregroundStyle(.secondary)
            }.padding(12)
            Divider()
            HSplitView {
                List(selection: $selected) {
                    ForEach(results) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(TextClips.summary(item.text!)).lineLimit(3)
                            Text("\(item.text!.count) " + L("characters"))
                                .font(.caption).foregroundStyle(.secondary)
                        }.padding(.vertical, 5).tag(item.id)
                    }
                }.frame(minWidth: 230, idealWidth: 300)
                VStack(alignment: .leading, spacing: 12) {
                    if let item = current, let text = item.text {
                        HStack {
                            Button { line.copy(item.id) } label: {
                                Label(line.copiedID == item.id ? L("Copied") : L("Copy"),
                                      systemImage: "doc.on.doc")
                            }
                            Spacer()
                            Button(L("Delete")) { line.eraseText(item.id) }
                        }
                        Divider()
                        ScrollView {
                            Text(text).textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        Text(L("Select a text card to read it"))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }.padding(16).frame(minWidth: 300)
            }
        }
    }
}
