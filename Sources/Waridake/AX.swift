import AppKit
import ApplicationServices

/// A thin wrapper over the Accessibility API: finding and moving windows.
enum AX {
    private static let systemWide = AXUIElementCreateSystemWide()

    /// The standard window at the given point (global CG coordinates, origin at
    /// the main screen's top left). Palettes, the desktop and our own windows
    /// give nil.
    static func window(atCG point: CGPoint) -> AXUIElement? {
        var element: AXUIElement?
        guard AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &element) == .success,
              let element else { return nil }
        return windowAncestor(of: element)
    }

    private static func windowAncestor(of element: AXUIElement) -> AXUIElement? {
        if stringValue(element, kAXRoleAttribute) == kAXWindowRole {
            return standardWindowOrNil(element)
        }
        if let window = elementValue(element, kAXWindowAttribute) {
            return standardWindowOrNil(window)
        }
        // Walk up the parents for elements without kAXWindowAttribute
        var current = element
        for _ in 0..<20 {
            guard let parent = elementValue(current, kAXParentAttribute) else { return nil }
            current = parent
            if stringValue(current, kAXRoleAttribute) == kAXWindowRole {
                return standardWindowOrNil(current)
            }
        }
        return nil
    }

    /// Only standard windows are eligible, which rules out the desktop,
    /// panels and this process's own overlays.
    private static func standardWindowOrNil(_ window: AXUIElement) -> AXUIElement? {
        guard stringValue(window, kAXSubroleAttribute) == kAXStandardWindowSubrole else { return nil }
        var pid: pid_t = 0
        AXUIElementGetPid(window, &pid)
        guard pid != getpid() else { return nil }
        return window
    }

    /// The window's position in global CG coordinates
    static func position(of window: AXUIElement) -> CGPoint? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &value) == .success,
              let value, CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
        var point = CGPoint.zero
        guard AXValueGetValue((value as! AXValue), .cgPoint, &point) else { return nil }
        return point
    }

    /// The window's current size
    static func size(of window: AXUIElement) -> CGSize? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &value) == .success,
              let value, CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
        var size = CGSize.zero
        guard AXValueGetValue((value as! AXValue), .cgSize, &size) else { return nil }
        return size
    }

    /// Every open standard window, skipping our own, minimized ones and palettes
    static func allStandardWindows() -> [AXUIElement] {
        var result: [AXUIElement] = []
        for app in NSWorkspace.shared.runningApplications
        where app.activationPolicy == .regular && app.processIdentifier != getpid() {
            let application = AXUIElementCreateApplication(app.processIdentifier)
            var value: CFTypeRef?
            guard AXUIElementCopyAttributeValue(
                application, kAXWindowsAttribute as CFString, &value) == .success,
                let windows = value as? [AXUIElement] else { continue }
            result.append(contentsOf: windows.filter(isArrangeable))
        }
        return result
    }

    private static func isArrangeable(_ window: AXUIElement) -> Bool {
        guard stringValue(window, kAXSubroleAttribute) == kAXStandardWindowSubrole else { return false }
        var value: CFTypeRef?
        if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &value) == .success,
           let minimized = value as? Bool, minimized {
            return false
        }
        return true
    }

    /// Moves and resizes a window into the given frame (global Cocoa coordinates)
    static func move(_ window: AXUIElement, toCocoaRect rect: NSRect) {
        guard let primary = NSScreen.screens.first else { return }
        var position = CGPoint(x: rect.minX, y: primary.frame.height - rect.maxY)
        var size = CGSize(width: rect.width, height: rect.height)
        // Shrink first, then place, then size again: some apps round the size
        // (minimum size constraints), and this gets closer to the target.
        setValue(window, kAXSizeAttribute, .cgSize, &size)
        setValue(window, kAXPositionAttribute, .cgPoint, &position)
        setValue(window, kAXSizeAttribute, .cgSize, &size)
    }

    // MARK: - Low level helpers

    private static func stringValue(_ element: AXUIElement, _ attribute: String) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success else { return nil }
        return value as? String
    }

    private static func elementValue(_ element: AXUIElement, _ attribute: String) -> AXUIElement? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success,
              let value, CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
        return (value as! AXUIElement)
    }

    private static func setValue<T>(_ element: AXUIElement, _ attribute: String, _ type: AXValueType, _ value: inout T) {
        guard let axValue = AXValueCreate(type, &value) else { return }
        AXUIElementSetAttributeValue(element, attribute as CFString, axValue)
    }
}
