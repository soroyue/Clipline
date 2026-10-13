import AppKit

/// UTF-8 files keep clipboard history local and let Quick Look/export work.
enum TextClips {
    static let maxBytes = 1_048_576
    static let ownType = NSPasteboard.PasteboardType("local.clipline.copied")
    static let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Clipline/Text", isDirectory: true)

    static func isText(_ url: URL) -> Bool { url.pathExtension.lowercased() == "txt" }

    static func read(_ url: URL) -> String? {
        guard isText(url),
              let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
              size <= maxBytes,
              let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        return text
    }

    static func save(_ text: String, in directory: URL = folder) throws -> URL {
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true,
                               attributes: [.posixPermissions: 0o700])
        let url = directory.appendingPathComponent("Text-\(UUID().uuidString).txt")
        // The private directory protects the atomic write's temporary file too.
        try Data(text.utf8).write(to: url, options: .atomic)
        do {
            try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
        } catch {
            try? fm.removeItem(at: url)
            throw error
        }
        return url
    }

    static func summary(_ text: String, limit: Int = 180) -> String {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = normalized.components(separatedBy: "\n")
        var paragraph: [String] = []
        for line in lines {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                if !paragraph.isEmpty { break }
            } else { paragraph.append(line) }
        }
        let first = paragraph.joined(separator: " ")
        return first.count > limit ? String(first.prefix(limit)) + "…" : first
    }

    /// Paper inside the upstream glass frame. Render at Retina resolution;
    /// the existing clothespin, swing, drag preview and falling animation all work.
    static func thumbnail(_ text: String, pixels: Int) -> NSImage {
        let size = NSSize(width: 272, height: 208)
        let image = NSImage(size: size)
        let scale = max(1, CGFloat(pixels) / size.width)
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width * scale),
                                  pixelsHigh: Int(size.height * scale), bitsPerSample: 8,
                                  samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = size
        image.addRepresentation(rep)
        // Draw into the explicit Retina bitmap. lockFocus can replace that
        // representation with one using the current screen's backing scale.
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: rep)!
        NSGraphicsContext.current = context
        context.cgContext.scaleBy(x: scale, y: scale)
        NSColor(calibratedRed: 0.98, green: 0.97, blue: 0.93, alpha: 1).setFill()
        NSRect(origin: .zero, size: size).fill()
        let ink = NSColor(calibratedWhite: 0.16, alpha: 1)
        (L("Text") as NSString).draw(at: NSPoint(x: 12, y: 174), withAttributes: [
            .font: NSFont.systemFont(ofSize: 24, weight: .semibold), .foregroundColor: ink])
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.lineSpacing = 2
        // Fill the available paper with consecutive paragraphs. Clip overflow;
        // the original, unabridged text remains available in the hover preview.
        let bodyRect = NSRect(x: 12, y: 12, width: 248, height: 154)
        NSGraphicsContext.saveGraphicsState()
        bodyRect.clip()
        (text as NSString).draw(with: bodyRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: NSFont.systemFont(ofSize: 14), .foregroundColor: ink,
                         .paragraphStyle: style])
        NSGraphicsContext.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
        return image
    }
}
