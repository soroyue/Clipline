import AppKit

// Original Clipline icon: two overlapping paper sheets, no upstream artwork.
let image = NSImage(size: NSSize(width: 1024, height: 1024))
image.lockFocus()
NSColor(calibratedRed: 0.17, green: 0.34, blue: 0.44, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 12, y: 12, width: 1000, height: 1000),
             xRadius: 220, yRadius: 220).fill()
NSColor(calibratedRed: 0.61, green: 0.80, blue: 0.81, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 230, y: 260, width: 500, height: 560),
             xRadius: 42, yRadius: 42).fill()
NSColor(calibratedRed: 0.98, green: 0.96, blue: 0.88, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 300, y: 190, width: 500, height: 560),
             xRadius: 42, yRadius: 42).fill()
NSColor(calibratedRed: 0.17, green: 0.34, blue: 0.44, alpha: 1).setFill()
for (y, width) in [(610, 330), (520, 330), (430, 230)] {
    NSBezierPath(roundedRect: NSRect(x: 380, y: CGFloat(y), width: CGFloat(width), height: 26),
                 xRadius: 13, yRadius: 13).fill()
}
image.unlockFocus()
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
try rep.representation(using: .png, properties: [:])!.write(
    to: URL(fileURLWithPath: CommandLine.arguments[1]))
