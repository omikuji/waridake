import AppKit

/// Watches window drags, shows the zones while Shift is held, and snaps the
/// window into whichever zone the mouse is released over. The heart of the app.
final class DragMonitor {
    var isEnabled = true

    private let layoutProvider: (NSScreen) -> Layout
    private let overlay = OverlayController()
    private var monitors: [Any] = []

    /// The window that was under the cursor on mouse down
    private var capturedWindow: AXUIElement?
    private var initialWindowPosition: CGPoint?
    /// Whether the window itself was seen moving. Keeps text selection and
    /// file drags inside a window from triggering the overlay.
    private var windowDragConfirmed = false

    init(layoutProvider: @escaping (NSScreen) -> Layout) {
        self.layoutProvider = layoutProvider
    }

    func start() {
        guard monitors.isEmpty else { return }
        add(.leftMouseDown) { [weak self] _ in self?.mouseDown() }
        add(.leftMouseDragged) { [weak self] event in self?.updateOverlay(shiftHeld: event.modifierFlags.contains(.shift)) }
        add(.leftMouseUp) { [weak self] _ in self?.mouseUp() }
        // React to Shift being pressed or released while the mouse sits still
        add(.flagsChanged) { [weak self] event in
            guard let self, self.capturedWindow != nil, NSEvent.pressedMouseButtons & 1 != 0 else { return }
            self.updateOverlay(shiftHeld: event.modifierFlags.contains(.shift))
        }
    }

    func stop() {
        monitors.forEach(NSEvent.removeMonitor)
        monitors.removeAll()
        reset()
    }

    /// Re-registers the monitors once accessibility is granted: monitors added
    /// while untrusted never receive any events.
    func restart() {
        stop()
        start()
    }

    private func add(_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> Void) {
        if let monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) {
            monitors.append(monitor)
        }
    }

    // MARK: - Events

    private func mouseDown() {
        reset()
        guard isEnabled else { return }
        capturedWindow = AX.window(atCG: mouseLocationCG())
        initialWindowPosition = capturedWindow.flatMap { AX.position(of: $0) }
    }

    private func updateOverlay(shiftHeld: Bool) {
        guard isEnabled, let window = capturedWindow else { return }
        guard shiftHeld else {
            if overlay.isVisible { overlay.hide() }
            return
        }
        if !windowDragConfirmed {
            guard let start = initialWindowPosition,
                  let current = AX.position(of: window),
                  abs(current.x - start.x) + abs(current.y - start.y) > 2 else { return }
            windowDragConfirmed = true
        }
        let mouse = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { NSPointInRect(mouse, $0.frame) }) else { return }
        overlay.show(layout: layoutProvider(screen), on: screen)
        overlay.updateHighlight(at: mouse)
    }

    private func mouseUp() {
        defer { reset() }
        guard let window = capturedWindow, overlay.isVisible,
              let rect = overlay.highlightedRect else { return }
        AX.move(window, toCocoaRect: rect)
    }

    private func reset() {
        overlay.hide()
        capturedWindow = nil
        initialWindowPosition = nil
        windowDragConfirmed = false
    }

    /// The mouse location in global CG coordinates (main screen top-left origin)
    private func mouseLocationCG() -> CGPoint {
        let location = NSEvent.mouseLocation
        let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
        return CGPoint(x: location.x, y: primaryHeight - location.y)
    }
}
