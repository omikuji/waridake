import AppKit

/// The katana drawn for the menu bar.
///
/// Menu bar art has to be a template image: only the alpha channel counts, and
/// macOS colours it black or white to match the bar. At this size the whole
/// sword is about eighteen points long, so the shapes are kept blunt on
/// purpose — anything finer disappears.
enum MenuBarIcon {
    static func katana(length: CGFloat = 17) -> NSImage {
        let image = NSImage(size: NSSize(width: length, height: length))
        image.lockFocus()
        draw(in: NSRect(x: 0, y: 0, width: length, height: length))
        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private static func draw(in rect: NSRect) {
        let scale = rect.width / 17
        NSColor.black.setFill()

        // Everything is built along a diagonal from the lower left to the tip
        let transform = NSAffineTransform()
        transform.translateX(by: rect.midX, yBy: rect.midY)
        transform.rotate(byDegrees: 34)
        transform.scale(by: scale)
        transform.concat()

        // A katana is mostly blade: roughly two and a half times the hilt
        let tip: CGFloat = 8.6
        let guardX: CGFloat = -3.6
        let hiltEnd: CGFloat = -8.3
        let halfWidth: CGFloat = 0.85
        let sori: CGFloat = 1.7   // the blade's curve

        // Blade: a curved sliver that comes to a point
        let blade = NSBezierPath()
        blade.move(to: NSPoint(x: guardX, y: -halfWidth))
        blade.curve(
            to: NSPoint(x: tip, y: 0.15),
            controlPoint1: NSPoint(x: tip * 0.4, y: -halfWidth - sori * 0.6),
            controlPoint2: NSPoint(x: tip * 0.8, y: -halfWidth - sori * 0.2))
        blade.curve(
            to: NSPoint(x: guardX, y: halfWidth),
            controlPoint1: NSPoint(x: tip * 0.8, y: halfWidth - sori * 0.5),
            controlPoint2: NSPoint(x: tip * 0.4, y: halfWidth - sori * 0.4))
        blade.close()
        blade.fill()

        // Tsuba: a short bar across the blade, the one detail that reads as a sword
        NSBezierPath(
            roundedRect: NSRect(x: guardX - 0.65, y: -2.2, width: 1.3, height: 4.4),
            xRadius: 0.6, yRadius: 0.6
        ).fill()

        // Tsuka
        NSBezierPath(
            roundedRect: NSRect(x: hiltEnd, y: -0.85, width: guardX - hiltEnd - 0.8, height: 1.7),
            xRadius: 0.85, yRadius: 0.85
        ).fill()
    }
}
