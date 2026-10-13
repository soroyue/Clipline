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
            window.title = "Clipline — " + L("Clipboard history")
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
    @State private var filter = 0
    @State private var selected: UUID?

    private var results: [Pegged] {
        line.items.reversed().filter {
            !$0.falling && (filter == 0 || (filter == 1 ? $0.isText : !$0.isText))
                && (query.isEmpty || ($0.text ?? $0.url.lastPathComponent).localizedCaseInsensitiveContains(query))
        }
    }

    private var current: Pegged? { results.first { $0.id == selected } }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField(L("Search text or image filenames"), text: $query)
                    .textFieldStyle(.roundedBorder)
                Text("\(results.count)").foregroundStyle(.secondary)
            }.padding(12)
            Picker(L("Content type"), selection: $filter) {
                Text(L("All")).tag(0)
                Text(L("Text")).tag(1)
                Text(L("Images")).tag(2)
            }.pickerStyle(.segmented).padding(.horizontal, 12).padding(.bottom, 10)
            Divider()
            HSplitView {
                List(selection: $selected) {
                    ForEach(results) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            if let text = item.text {
                                Label(TextClips.summary(text), systemImage: "text.alignleft").lineLimit(3)
                                Text("\(text.count) " + L("characters")).font(.caption).foregroundStyle(.secondary)
                            } else {
                                HStack {
                                    Image(nsImage: item.thumb).resizable().scaledToFit().frame(width: 54, height: 40)
                                    Text(item.url.lastPathComponent).lineLimit(2)
                                }
                            }
                        }.padding(.vertical, 5).tag(item.id)
                    }
                }.frame(minWidth: 230, idealWidth: 300)
                VStack(alignment: .leading, spacing: 12) {
                    if let item = current {
                        HStack {
                            Button { line.copy(item.id) } label: {
                                Label(line.copiedID == item.id ? L("Copied") : L("Copy"),
                                      systemImage: "doc.on.doc")
                            }
                            Spacer()
                            if !item.isText {
                                Button(L("Open")) { line.open(item.id) }
                            }
                            Button(item.isText ? L("Delete") : line.isInInbox(item.id) ? L("Move to Trash") : L("Take down")) {
                                line.discard(item.id)
                            }
                        }
                        Divider()
                        if let text = item.text {
                            ScrollView {
                                Text(text).textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        } else {
                            Image(nsImage: item.thumb).resizable().scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Text(L("Thumbnail preview. Open to view the original.")).font(.caption).foregroundStyle(.secondary)
                        }
                    } else {
                        Text(L("Select an item to preview it"))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }.padding(16).frame(minWidth: 300)
            }
        }
    }
}
