import AppKit

/// The zone overlay shown while dragging a window.
/// Just a ZoneView inside a transparent window that never takes clicks.
final class OverlayController {
    private var window: NSWindow?
    private var zoneView: ZoneView?
    /// Zone frames in global Cocoa coordinates
    private var rects: [NSRect] = []

    /// The highlighted zone's frame, in global Cocoa coordinates
    private(set) var highlightedRect: NSRect?

    var isVisible: Bool { window?.isVisible ?? false }

    func show(layout: Layout, on screen: NSScreen) {
        let newRects = layout.zoneRects(on: screen)
        if isVisible, newRects == rects { return }
        rects = newRects
        highlightedRect = nil

        let window = self.window ?? makeWindow()
        window.setFrame(screen.frame, display: false)
        let view = ZoneView(frame: NSRect(origin: .zero, size: screen.frame.size))
        view.rects = rects.map { $0.offsetBy(dx: -screen.frame.minX, dy: -screen.frame.minY) }
        window.contentView = view
        zoneView = view
        window.orderFrontRegardless()
    }

    /// Updates the highlight from the mouse location (global Cocoa coordinates)
    func updateHighlight(at point: NSPoint) {
        guard let zoneView else { return }
        let index = rects.firstIndex { $0.contains(point) }
        highlightedRect = index.map { rects[$0] }
        let newIndex = index ?? -1
        if zoneView.highlightIndex != newIndex {
            zoneView.highlightIndex = newIndex
            zoneView.needsDisplay = true
        }
    }

    func hide() {
        window?.orderOut(nil)
        highlightedRect = nil
        rects = []
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .screenSaver
        window.ignoresMouseEvents = true
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        self.window = window
        return window
    }
}

/// A view that only draws the zone frames
final class ZoneView: NSView {
    var rects: [NSRect] = []
    var highlightIndex: Int = -1

    override func draw(_ dirtyRect: NSRect) {
        let accent = NSColor.controlAccentColor
        for (index, rect) in rects.enumerated() {
            let active = index == highlightIndex
            let path = NSBezierPath(roundedRect: rect, xRadius: 10, yRadius: 10)
            (active ? accent.withAlphaComponent(0.35) : accent.withAlphaComponent(0.12)).setFill()
            path.fill()
            (active ? accent : accent.withAlphaComponent(0.5)).setStroke()
            path.lineWidth = active ? 3 : 1.5
            path.stroke()
        }
    }
}
