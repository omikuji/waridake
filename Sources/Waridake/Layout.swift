import AppKit
import Foundation

/// A single zone, given as a fraction of the screen's working area (the part
/// left over by the menu bar and the Dock). y is measured from the top edge so
/// the config file reads the way the screen looks.
struct Zone {
    var x: Double
    var y: Double
    var w: Double
    var h: Double
}

struct Layout {
    /// Space between zones (pt), applied as a gap/2 inset on every side
    var gap: Double
    var zones: [Zone]

    /// The one definition of the default layout: two equal columns.
    /// Deliberately plain, because it has to be useful on a laptop screen as
    /// well as on a wide external display. Written by hand rather than encoded,
    /// since this text is also the template for the config file people edit.
    static let defaultText = """
    {
      "gap": 8,
      "zones": [
        { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
        { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
      ]
    }
    """

    /// defaultText, parsed. Parsing cannot realistically fail, but this is the
    /// last resort when the config file is missing or broken, so it falls back
    /// to a single full-screen zone.
    static let `default`: Layout =
        (try? JSONDecoder().decode(Layout.self, from: Data(defaultText.utf8)))
        ?? Layout(gap: 8, zones: [Zone(x: 0, y: 0, w: 1, h: 1)])

    /// Writes 0.25 as 0.25 and 1.0 as 1, to match a hand-written config file
    static func number(_ value: Double) -> String {
        let rounded = (value * 10000).rounded() / 10000
        return rounded == rounded.rounded()
            ? String(Int(rounded))
            : String(format: "%g", rounded)
    }

    /// The zone frames on a screen, in global Cocoa coordinates (bottom-left origin)
    func zoneRects(on screen: NSScreen) -> [NSRect] {
        let frame = screen.visibleFrame
        let inset = gap / 2
        return zones.map { z in
            let rect = NSRect(
                x: frame.minX + z.x * frame.width,
                // y counts from the top, so flip it into Cocoa coordinates
                y: frame.minY + (1 - z.y - z.h) * frame.height,
                width: z.w * frame.width,
                height: z.h * frame.height
            )
            return rect.insetBy(dx: inset, dy: inset)
        }
    }
}

extension Zone: Decodable {}

extension Layout: Decodable {
    private enum CodingKeys: String, CodingKey { case gap, zones }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        gap = try container.decodeIfPresent(Double.self, forKey: .gap) ?? 8
        zones = try container.decode([Zone].self, forKey: .zones)
    }
}

/// One config file. Every display can have its own layout, because screens
/// differ in shape and size and a single split never suits all of them.
struct LayoutSet {
    /// Used for displays that have no entry in `displays`
    var base: Layout
    /// Display UUID to its named layout
    var displays: [String: Entry]

    struct Entry {
        var name: String
        var layout: Layout
        /// When this display's layout was last used, so that settings for
        /// displays no longer in use can be spotted and removed.
        var usedAt: Date?
    }

    static let `default` = LayoutSet(base: .default, displays: [:])

    func layout(forKey key: String) -> Layout {
        displays[key]?.layout ?? base
    }

    func setting(_ layout: Layout, forKey key: String, name: String) -> LayoutSet {
        var copy = self
        copy.displays[key] = Entry(name: name, layout: layout, usedAt: displays[key]?.usedAt)
        return copy
    }

    /// Records a use. Displays without an entry get a copy of the default.
    func marking(_ key: String, name: String, usedAt: Date) -> LayoutSet {
        var copy = self
        var entry = copy.displays[key] ?? Entry(name: name, layout: base, usedAt: nil)
        entry.name = name
        entry.usedAt = usedAt
        copy.displays[key] = entry
        return copy
    }

    /// Replaces the layout that displays without an entry of their own use.
    func settingBase(_ layout: Layout) -> LayoutSet {
        var copy = self
        copy.base = layout
        return copy
    }

    func removing(_ key: String) -> LayoutSet {
        var copy = self
        copy.displays.removeValue(forKey: key)
        return copy
    }

    /// JSON in the same shape as the config file, so layouts built in the
    /// editor stay readable and editable by hand.
    func jsonText() -> String {
        var lines = ["{"]
        lines.append("  \"gap\": \(Layout.number(base.gap)),")
        lines.append("  \"zones\": [")
        lines.append(Self.zoneLines(base.zones, indent: 4))
        lines.append(displays.isEmpty ? "  ]" : "  ],")

        if !displays.isEmpty {
            lines.append("  \"displays\": {")
            let keys = displays.keys.sorted()
            for (index, key) in keys.enumerated() {
                guard let entry = displays[key] else { continue }
                lines.append("    \"\(Self.escaped(key))\": {")
                lines.append("      \"name\": \"\(Self.escaped(entry.name))\",")
                if let usedAt = entry.usedAt {
                    lines.append("      \"usedAt\": \"\(Self.timestamps.string(from: usedAt))\",")
                }
                lines.append("      \"gap\": \(Layout.number(entry.layout.gap)),")
                lines.append("      \"zones\": [")
                lines.append(Self.zoneLines(entry.layout.zones, indent: 8))
                lines.append("      ]")
                lines.append(index == keys.count - 1 ? "    }" : "    },")
            }
            lines.append("  }")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private static func zoneLines(_ zones: [Zone], indent: Int) -> String {
        let pad = String(repeating: " ", count: indent)
        return zones.map { z in
            "\(pad){ \"x\": \(Layout.number(z.x)), \"y\": \(Layout.number(z.y)), "
                + "\"w\": \(Layout.number(z.w)), \"h\": \(Layout.number(z.h)) }"
        }.joined(separator: ",\n")
    }

    /// Timestamps are ISO8601, readable by both people and machines
    static let timestamps: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func escaped(_ text: String) -> String {
        text.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

extension LayoutSet: Decodable {
    private enum CodingKeys: String, CodingKey { case displays }

    init(from decoder: Decoder) throws {
        // gap / zones stay at the top level, so older config files still load
        base = try Layout(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displays = try container.decodeIfPresent([String: Entry].self, forKey: .displays) ?? [:]
    }
}

extension LayoutSet.Entry: Decodable {
    private enum CodingKeys: String, CodingKey { case name, usedAt }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        usedAt = try container.decodeIfPresent(String.self, forKey: .usedAt)
            .flatMap(LayoutSet.timestamps.date(from:))
        layout = try Layout(from: decoder)
    }
}

/// Reads and writes the config file (~/.config/waridake/layout.json)
final class LayoutStore {
    private(set) var set: LayoutSet = .default

    /// How many past versions to keep
    static let historyLimit = 10
    /// How often the last-used date is written back; keeps drags from saving
    private static let markInterval: TimeInterval = 600

    /// The layout for a display, or the default one. Looking it up counts as
    /// using it, so the date is noted here.
    func layout(for screen: NSScreen) -> Layout {
        let key = Display.key(for: screen)
        markUsed(key: key, name: Display.name(for: screen))
        return set.layout(forKey: key)
    }

    private func markUsed(key: String, name: String) {
        let now = Date()
        if let usedAt = set.displays[key]?.usedAt,
           now.timeIntervalSince(usedAt) < Self.markInterval {
            return
        }
        set = set.marking(key, name: name, usedAt: now)
        // The layout itself did not change, so this is not worth a history entry
        try? write(set.jsonText())
    }

    let url: URL

    static let defaultURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/waridake/layout.json")

    init(url: URL = LayoutStore.defaultURL) {
        self.url = url
    }

    /// Writes the default on first launch, then reads the file
    func loadOrCreate() {
        if !FileManager.default.fileExists(atPath: url.path) {
            writeDefault()
        }
        load()
    }

    /// On failure the previous layout stays in effect and the app keeps working
    @discardableResult
    func load() -> Bool {
        do {
            let data = try Data(contentsOf: url)
            set = try JSONDecoder().decode(LayoutSet.self, from: data)
            return true
        } catch {
            NSLog("Waridake: could not read layout.json: \(error)")
            return false
        }
    }

    private func writeDefault() {
        do {
            try write(Layout.defaultText)
        } catch {
            NSLog("Waridake: could not create layout.json: \(error)")
        }
    }

    // MARK: - For the editors

    /// The config file verbatim, creating it from the template if needed
    func currentText() -> String {
        if !FileManager.default.fileExists(atPath: url.path) { writeDefault() }
        return (try? String(contentsOf: url, encoding: .utf8)) ?? Layout.defaultText
    }

    /// Validates before saving, then applies straight away. If validation
    /// fails the file is left untouched and the reason is returned (nil = ok).
    func save(text: String) -> String? {
        if let message = Self.validationError(in: text) { return message }
        do {
            try write(text, archive: true)
        } catch {
            return L("Could not save: %@", error.localizedDescription)
        }
        load()
        return nil
    }

    /// Saving from the visual editor: only that screen's entry is replaced.
    func save(layout: Layout, for screen: NSScreen) -> String? {
        let updated = set.setting(
            layout, forKey: Display.key(for: screen), name: Display.name(for: screen))
        return save(text: updated.jsonText())
    }

    private func write(_ text: String, archive: Bool = false) throws {
        if archive { archiveCurrent() }
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(text.utf8).write(to: url, options: .atomic)
    }

    // MARK: - Edit history

    var historyDirectory: URL {
        url.deletingLastPathComponent().appendingPathComponent("history")
    }

    struct Snapshot {
        var url: URL
        var date: Date
    }

    /// Past versions, newest first
    func snapshots() -> [Snapshot] {
        let contents = (try? FileManager.default.contentsOfDirectory(
            at: historyDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        return contents
            .filter { $0.pathExtension == "json" }
            .compactMap { file in
                let date = (try? file.resourceValues(forKeys: [.contentModificationDateKey]))?
                    .contentModificationDate
                return Snapshot(url: file, date: date ?? .distantPast)
            }
            .sorted { $0.date > $1.date }
    }

    /// Restores a past version. The state before restoring is archived too,
    /// so restoring can itself be undone.
    func restore(_ snapshot: Snapshot) -> String? {
        guard let text = try? String(contentsOf: snapshot.url, encoding: .utf8) else {
            return L("Could not read that version")
        }
        return save(text: text)
    }

    /// Archives the current file before it is overwritten
    private func archiveCurrent() {
        guard let data = try? Data(contentsOf: url) else { return }
        try? FileManager.default.createDirectory(
            at: historyDirectory, withIntermediateDirectories: true)
        let stamp = Self.stamps.string(from: Date())
        try? data.write(to: historyDirectory.appendingPathComponent("layout-\(stamp).json"))

        for old in snapshots().dropFirst(Self.historyLimit) {
            try? FileManager.default.removeItem(at: old.url)
        }
    }

    /// Milliseconds included so saves in the same second do not overwrite
    private static let stamps: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
        return formatter
    }()

    /// Promotes a display's layout to the default that unlisted displays use
    func makeDefault(key: String) -> String? {
        guard let entry = set.displays[key] else { return nil }
        return save(text: set.settingBase(entry.layout).jsonText())
    }

    /// Removes the settings of a display that is no longer used
    func removeDisplay(key: String) -> String? {
        save(text: set.removing(key).jsonText())
    }

    /// nil means the text is a valid layout. Keeps broken JSON from being saved.
    static func validationError(in text: String) -> String? {
        let data = Data(text.utf8)
        do {
            _ = try JSONSerialization.jsonObject(with: data)
        } catch {
            let detail = (error as NSError).userInfo["NSDebugDescription"] as? String
            return L("JSON syntax error: %@", detail ?? error.localizedDescription)
        }
        do {
            let set = try JSONDecoder().decode(LayoutSet.self, from: data)
            if set.base.zones.isEmpty {
                return L("\"zones\" is empty (snapping needs at least one zone)")
            }
            for (key, entry) in set.displays where entry.layout.zones.isEmpty {
                return L("\"zones\" is empty for display %@", entry.name.isEmpty ? key : entry.name)
            }
        } catch let error as DecodingError {
            return message(for: error)
        } catch {
            return error.localizedDescription
        }
        return nil
    }

    private static func message(for error: DecodingError) -> String {
        switch error {
        case let .keyNotFound(key, context):
            return L("%@ is missing \"%@\"", path(context.codingPath), key.stringValue)
        case let .typeMismatch(_, context):
            return L("%@ has the wrong kind of value (write a number)", path(context.codingPath))
        case let .valueNotFound(_, context):
            return L("%@ has no value", path(context.codingPath))
        case let .dataCorrupted(context):
            return context.debugDescription
        @unknown default:
            return error.localizedDescription
        }
    }

    /// Turns a coding path into something familiar like zones[2].w
    private static func path(_ codingPath: [CodingKey]) -> String {
        guard !codingPath.isEmpty else { return L("the file") }
        return codingPath.reduce(into: "") { result, key in
            if let index = key.intValue {
                result += "[\(index)]"
            } else {
                result += result.isEmpty ? key.stringValue : ".\(key.stringValue)"
            }
        }
    }
}
