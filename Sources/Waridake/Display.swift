import AppKit

/// How displays are told apart.
/// A display UUID survives unplugging and reboots, so it is used as the
/// key for per-display settings.
enum Display {
    static func key(for screen: NSScreen) -> String {
        guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber,
              let uuid = CGDisplayCreateUUIDFromDisplayID(
                CGDirectDisplayID(number.uint32Value))?.takeRetainedValue(),
              let string = CFUUIDCreateString(nil, uuid) as String?
        else {
            // Fallback for setups where no UUID is available.
            return "\(screen.localizedName) \(Int(screen.frame.width))x\(Int(screen.frame.height))"
        }
        return string
    }

    static func name(for screen: NSScreen) -> String {
        screen.localizedName
    }
}
