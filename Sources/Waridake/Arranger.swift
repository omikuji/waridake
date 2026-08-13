import AppKit

/// Puts every open window back into the zone nearest to it.
/// For cleaning up windows that have drifted out of place.
enum Arranger {
    /// How far off a window may be and still count as already in place (pt)
    private static let tolerance: CGFloat = 2

    /// Returns how many windows moved. The layout is looked up per screen.
    @discardableResult
    static func arrangeAll(layoutForScreen: (NSScreen) -> Layout) -> Int {
        guard let primary = NSScreen.screens.first else { return 0 }
        var moved = 0
        for window in AX.allStandardWindows() {
            guard let position = AX.position(of: window), let size = AX.size(of: window) else { continue }
            // Accessibility uses a top-left origin, Cocoa a bottom-left one
            let frame = NSRect(
                x: position.x,
                y: primary.frame.height - position.y - size.height,
                width: size.width, height: size.height)

            guard let screen = screen(containing: frame) else { continue }
            let rects = layoutForScreen(screen).zoneRects(on: screen)
            guard let target = nearestZone(to: frame, in: rects) else { continue }
            guard !isSettled(frame, in: target) else { continue }
            AX.move(window, toCocoaRect: target)
            moved += 1
        }
        return moved
    }

    /// The screen holding the window's center; falls back to the main one.
    private static func screen(containing frame: NSRect) -> NSScreen? {
        let center = NSPoint(x: frame.midX, y: frame.midY)
        return NSScreen.screens.first { NSPointInRect(center, $0.frame) }
            ?? NSScreen.main ?? NSScreen.screens.first
    }

    /// The zone whose center is closest
    private static func nearestZone(to frame: NSRect, in rects: [NSRect]) -> NSRect? {
        rects.min { first, second in
            distance(from: frame, to: first) < distance(from: frame, to: second)
        }
    }

    private static func distance(from frame: NSRect, to rect: NSRect) -> CGFloat {
        let dx = frame.midX - rect.midX
        let dy = frame.midY - rect.midY
        return dx * dx + dy * dy
    }

    private static func isSettled(_ frame: NSRect, in rect: NSRect) -> Bool {
        abs(frame.minX - rect.minX) < tolerance && abs(frame.minY - rect.minY) < tolerance
            && abs(frame.width - rect.width) < tolerance
            && abs(frame.height - rect.height) < tolerance
    }
}
