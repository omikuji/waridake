import AppKit

/// A full-screen overlay for shaping the zones directly, at the real size of
/// the screen, so nobody has to think in fractions. Saving writes layout.json,
/// which is the same file the JSON editor works on.
final class ZoneEditor {
    private let store: LayoutStore
    /// Reports when editing starts and ends, so snapping can pause
    private let onStateChange: (Bool) -> Void

    /// One display's editing surface
    private struct Pane {
        var window: NSWindow
        var view: ZoneEditorView
        var screen: NSScreen
    }

    private var panes: [Pane] = []

    var isEditing: Bool { !panes.isEmpty }

    init(store: LayoutStore, onStateChange: @escaping (Bool) -> Void) {
        self.store = store
        self.onStateChange = onStateChange
    }

    /// Opens on every connected display at once. Screens differ in shape, so
    /// each one keeps its own layout.
    func show() {
        guard panes.isEmpty else { return }
        let screens = NSScreen.screens
        for screen in screens {
            // Zones are measured against visibleFrame, so the editing surface
            // matches it. The menu bar and the Dock stay usable.
            let frame = screen.visibleFrame
            let window = EditorWindow(
                contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.level = .modalPanel
            window.isReleasedWhenClosed = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]

            let view = ZoneEditorView(frame: NSRect(origin: .zero, size: frame.size))
            view.displayName = Display.name(for: screen)
            view.savesEveryDisplay = screens.count > 1
            view.layout = store.layout(for: screen)
            view.onSave = { [weak self] in self?.saveAll() }
            view.onCancel = { [weak self] in self?.close() }
            window.contentView = view

            panes.append(Pane(window: window, view: view, screen: screen))
        }

        onStateChange(true)
        NSApp.activate(ignoringOtherApps: true)
        for pane in panes { pane.window.orderFrontRegardless() }

        // Start on whichever screen the mouse is on
        let mouse = NSEvent.mouseLocation
        let first = panes.first { NSMouseInRect(mouse, $0.screen.frame, false) } ?? panes.first
        if let first {
            first.window.makeKeyAndOrderFront(nil)
            first.window.makeFirstResponder(first.view)
        }
    }

    /// Saving on any screen writes the layouts of all open displays
    private func saveAll() {
        for pane in panes {
            guard let message = store.save(layout: pane.view.currentLayout, for: pane.screen) else {
                continue
            }
            let alert = NSAlert()
            alert.messageText = L("Could not save")
            alert.informativeText = "\(Display.name(for: pane.screen)): \(message)"
            alert.runModal()
            return
        }
        close()
    }

    private func close() {
        for pane in panes { pane.window.orderOut(nil) }
        panes = []
        onStateChange(false)
    }
}

/// Exists only so a borderless window can take keyboard input
private final class EditorWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - Editing surface

/// Hit testing and editing. Coordinates are kept the way Layout stores them,
/// as fractions from the top left, and only flipped into Cocoa coordinates
/// (bottom-left origin) for drawing.
final class ZoneEditorView: NSView {
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    /// Which display is being edited (shown in the HUD)
    var displayName = ""
    /// Whether saving covers every display (true with more than one screen)
    var savesEveryDisplay = false

    /// The layout as it stands
    var currentLayout: Layout { Layout(gap: gap, zones: zones) }

    var layout = Layout.default {
        didSet {
            zones = layout.zones
            gap = layout.gap
            configureGapPopUp()
        }
    }

    /// One boundary. value is a fraction: x from the left for a vertical
    /// boundary, y from the top for a horizontal one.
    private struct Boundary {
        var isVertical: Bool
        var value: Double
    }

    private struct Drag {
        var boundary: Boundary
        /// The boundary mirrored across the screen center, moved along with ⌥
        var mirror: Boundary?
        var isSymmetric = false
    }

    private var zones: [Zone] = []
    private var gap: Double = 8
    /// Gap choices; the current value is added if it is not among them
    private let gapPopUp = NSPopUpButton()
    private var gapChoices: [Double] = []
    private var selected: Int?
    private var history: [[Zone]] = []

    private var drag: Drag?
    private var hover: Boundary?
    private var trackingArea: NSTrackingArea?

    /// The right-clicked zone, read by the menu items
    private var menuZone: Int?

    /// The Merge button kept on every mergeable boundary
    private struct MergeButton {
        var rect: NSRect
        var first: Int
        var second: Int
    }

    private var mergeButtons: [MergeButton] = []
    private var hoveredMergeButton: Int?
    private let mergeButtonSize = NSSize(width: 56, height: 26)

    /// Zones never shrink below this, or they become impossible to grab
    private let minSize = 0.05
    /// How close to a boundary counts as grabbing it (pt)
    private let grabDistance: CGFloat = 8
    /// Fractions this close count as equal
    private let epsilon = 0.002

    override var isFlipped: Bool { false }
    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        addHUD()
        updateTrackingAreas()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
        let area = NSTrackingArea(
            rect: bounds, options: [.activeAlways, .mouseMoved, .inVisibleRect],
            owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }

    // MARK: - Coordinates

    private func rect(of zone: Zone) -> NSRect {
        NSRect(
            x: zone.x * bounds.width,
            y: (1 - zone.y - zone.h) * bounds.height,
            width: zone.w * bounds.width,
            height: zone.h * bounds.height)
    }

    private func ratioX(_ x: CGFloat) -> Double { Double(x / bounds.width) }
    /// A fraction from the top edge, the way Layout stores y
    private func ratioY(_ y: CGFloat) -> Double { Double(1 - y / bounds.height) }

    private func start(_ zone: Zone, _ isVertical: Bool) -> Double { isVertical ? zone.x : zone.y }
    private func end(_ zone: Zone, _ isVertical: Bool) -> Double {
        isVertical ? zone.x + zone.w : zone.y + zone.h
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.35).setFill()
        bounds.fill()

        rebuildMergeButtons()
        let accent = NSColor.controlAccentColor
        let inset = gap / 2
        for (index, zone) in zones.enumerated() {
            let frame = rect(of: zone).insetBy(dx: inset, dy: inset)
            let path = NSBezierPath(roundedRect: frame, xRadius: 10, yRadius: 10)
            let isSelected = index == selected
            (isSelected ? accent.withAlphaComponent(0.42) : accent.withAlphaComponent(0.16)).setFill()
            path.fill()
            (isSelected ? accent : accent.withAlphaComponent(0.6)).setStroke()
            path.lineWidth = isSelected ? 3 : 1.5
            path.stroke()
            drawSize(of: zone, in: frame)
        }

        if let drag {
            drawGuide(drag.boundary, alpha: 0.9)
            if drag.isSymmetric, let mirror = drag.mirror { drawGuide(mirror, alpha: 0.9) }
        } else if let hover {
            drawGuide(hover, alpha: 0.5)
        }

        drawMergeButtons()
    }

    private func drawMergeButtons() {
        let text = L("Merge")
        for (index, button) in mergeButtons.enumerated() {
            let isHovered = index == hoveredMergeButton
            let path = NSBezierPath(roundedRect: button.rect, xRadius: 13, yRadius: 13)
            (isHovered ? NSColor.white : NSColor.white.withAlphaComponent(0.9)).setFill()
            path.fill()
            NSColor.black.withAlphaComponent(isHovered ? 0.5 : 0.25).setStroke()
            path.lineWidth = 1
            path.stroke()

            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: NSColor.black.withAlphaComponent(isHovered ? 0.9 : 0.75),
            ]
            let size = (text as NSString).size(withAttributes: attributes)
            (text as NSString).draw(
                at: NSPoint(x: button.rect.midX - size.width / 2, y: button.rect.midY - size.height / 2),
                withAttributes: attributes)
        }
    }

    /// Collects every pair that would merge into a rectangle and puts a button
    /// at the middle of the edge they share
    private func rebuildMergeButtons() {
        var buttons: [MergeButton] = []
        for first in zones.indices {
            for second in zones.indices where second > first && isMergeable(first, second) {
                guard let center = sharedEdgeCenter(first, second) else { continue }
                buttons.append(MergeButton(
                    rect: NSRect(
                        x: center.x - mergeButtonSize.width / 2,
                        y: center.y - mergeButtonSize.height / 2,
                        width: mergeButtonSize.width, height: mergeButtonSize.height),
                    first: first, second: second))
            }
        }
        mergeButtons = buttons
    }

    /// The midpoint of the edge two zones share, in view coordinates
    private func sharedEdgeCenter(_ first: Int, _ second: Int) -> NSPoint? {
        let a = zones[first]
        let b = zones[second]
        if abs(a.y - b.y) < epsilon, abs(a.h - b.h) < epsilon {  // side by side
            return NSPoint(
                x: max(a.x, b.x) * bounds.width,
                y: (1 - (a.y + a.h / 2)) * bounds.height)
        }
        if abs(a.x - b.x) < epsilon, abs(a.w - b.w) < epsilon {  // stacked
            return NSPoint(
                x: (a.x + a.w / 2) * bounds.width,
                y: (1 - max(a.y, b.y)) * bounds.height)
        }
        return nil
    }

    /// Puts the size in the middle of a zone, as a percentage so that the
    /// fractions never have to be read
    private func drawSize(of zone: Zone, in frame: NSRect) {
        let text = "\(percent(zone.w)) × \(percent(zone.h))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15, weight: .medium),
            .foregroundColor: NSColor.white.withAlphaComponent(0.85),
        ]
        let size = (text as NSString).size(withAttributes: attributes)
        guard size.width < frame.width - 12, size.height < frame.height - 12 else { return }
        (text as NSString).draw(
            at: NSPoint(x: frame.midX - size.width / 2, y: frame.midY - size.height / 2),
            withAttributes: attributes)
    }

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func drawGuide(_ boundary: Boundary, alpha: CGFloat) {
        NSColor.white.withAlphaComponent(alpha).setFill()
        if boundary.isVertical {
            let x = CGFloat(boundary.value) * bounds.width
            NSRect(x: x - 1.5, y: 0, width: 3, height: bounds.height).fill()
        } else {
            let y = (1 - CGFloat(boundary.value)) * bounds.height
            NSRect(x: 0, y: y - 1.5, width: bounds.width, height: 3).fill()
        }
    }

    // MARK: - Mouse

    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        let overButton = mergeButtons.firstIndex { $0.rect.contains(point) }
        let found = overButton == nil ? boundary(at: point) : nil
        let changed = overButton != hoveredMergeButton
            || found?.value != hover?.value || found?.isVertical != hover?.isVertical
        hoveredMergeButton = overButton
        hover = found

        if overButton != nil {
            NSCursor.pointingHand.set()
        } else if let found {
            (found.isVertical ? NSCursor.resizeLeftRight : NSCursor.resizeUpDown).set()
        } else {
            NSCursor.arrow.set()
        }
        if changed { needsDisplay = true }
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        // The Merge button wins over dragging the boundary underneath it
        if let index = mergeButtons.firstIndex(where: { $0.rect.contains(point) }) {
            let button = mergeButtons[index]
            pushHistory()
            hoveredMergeButton = nil
            merge(button.first, button.second)
            return
        }

        if event.clickCount == 2, let index = zoneIndex(at: point) {
            // Cut along the longer side; ⌥ flips the direction
            var isVertical = zones[index].w >= zones[index].h
            if event.modifierFlags.contains(.option) { isVertical.toggle() }
            splitAtPoint(index, point: point, isVertical: isVertical)
            return
        }

        if let found = boundary(at: point) {
            pushHistory()
            drag = Drag(boundary: found, mirror: mirror(of: found))
            return
        }

        selected = zoneIndex(at: point)
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard var current = drag else { return }
        let point = convert(event.locationInWindow, from: nil)
        let raw = current.boundary.isVertical ? ratioX(point.x) : ratioY(point.y)
        let target = snap(raw, isVertical: current.boundary.isVertical, ignoring: current.boundary.value)

        let achieved = moveBoundary(current.boundary, to: target)
        current.boundary.value = achieved
        current.isSymmetric = event.modifierFlags.contains(.option)
        if current.isSymmetric, let mirror = current.mirror {
            let moved = moveBoundary(mirror, to: 1 - achieved)
            current.mirror?.value = moved
        }
        drag = current
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard drag != nil else { return }
        drag = nil
        needsDisplay = true
    }

    // MARK: - Context menu

    override func rightMouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        guard let menu = contextMenu(at: point) else { return }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    /// Builds the menu for the right-clicked zone and remembers the target the
    /// items act on. Merging is not here: that is the boundary button's job.
    func contextMenu(at point: NSPoint) -> NSMenu? {
        menuZone = nil
        guard let index = zoneIndex(at: point) else { return nil }
        menuZone = index
        selected = index
        needsDisplay = true
        return zoneMenu(index)
    }

    private func zoneMenu(_ index: Int) -> NSMenu {
        let menu = NSMenu()
        add(menu, L("Split in 2 (left/right)"), #selector(splitVertical2))
        add(menu, L("Split in 3 (left/right)"), #selector(splitVertical3))
        add(menu, L("Split in 2 (top/bottom)"), #selector(splitHorizontal2))
        add(menu, L("Split in 3 (top/bottom)"), #selector(splitHorizontal3))

        menu.addItem(.separator())
        let column = columnGroup(of: index)
        if column.count >= 2 {
            add(menu, L("Distribute this column evenly (%d)", column.count), #selector(equalizeColumn))
        }
        let row = rowGroup(of: index)
        if row.count >= 2 {
            add(menu, L("Distribute this row evenly (%d)", row.count), #selector(equalizeRow))
        }
        if column.count < 2, row.count < 2 {
            add(menu, L("Nothing lined up to distribute"), nil)
        }

        menu.addItem(.separator())
        // An edge on the screen border cannot move, so such a zone cannot center
        add(
            menu, L("Center horizontally on screen"),
            canCenter(index, isVertical: true) ? #selector(centerHorizontally) : nil)
        add(
            menu, L("Center vertically on screen"),
            canCenter(index, isVertical: false) ? #selector(centerVertically) : nil)

        menu.addItem(.separator())
        add(menu, L("Undo"), history.isEmpty ? nil : #selector(undoEdit))
        return menu
    }

    /// Items without an action stay greyed out and only explain themselves
    private func add(_ menu: NSMenu, _ title: String, _ action: Selector?) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = action == nil ? nil : self
        item.isEnabled = action != nil
        menu.addItem(item)
    }

    // MARK: - Menu actions

    @objc private func splitVertical2() { divideMenuZone(into: 2, isVertical: true) }
    @objc private func splitVertical3() { divideMenuZone(into: 3, isVertical: true) }
    @objc private func splitHorizontal2() { divideMenuZone(into: 2, isVertical: false) }
    @objc private func splitHorizontal3() { divideMenuZone(into: 3, isVertical: false) }

    private func divideMenuZone(into count: Int, isVertical: Bool) {
        guard let index = menuZone else { return }
        divide(index, into: count, isVertical: isVertical)
    }

    @objc private func equalizeColumn() {
        guard let index = menuZone else { return }
        equalize(columnGroup(of: index), isVertical: false)
    }

    @objc private func equalizeRow() {
        guard let index = menuZone else { return }
        equalize(rowGroup(of: index), isVertical: true)
    }

    @objc private func centerHorizontally() {
        guard let index = menuZone else { return }
        center(index, isVertical: true)
    }

    @objc private func centerVertically() {
        guard let index = menuZone else { return }
        center(index, isVertical: false)
    }

    @objc private func undoEdit() {
        guard let previous = history.popLast() else { NSSound.beep(); return }
        zones = previous
        selected = nil
        needsDisplay = true
    }

    // MARK: - Boundaries

    private func zoneIndex(at point: NSPoint) -> Int? {
        zones.indices.first { rect(of: zones[$0]).contains(point) }
    }

    /// Finds a grabbable boundary. The screen border is excluded: moving it
    /// would mean nothing.
    private func boundary(at point: NSPoint) -> Boundary? {
        var best: (boundary: Boundary, distance: CGFloat)?
        for zone in zones {
            let frame = rect(of: zone)
            let candidates: [(Bool, Double, CGFloat)] = [
                (true, zone.x, abs(point.x - frame.minX)),
                (true, zone.x + zone.w, abs(point.x - frame.maxX)),
                (false, zone.y, abs(point.y - frame.maxY)),
                (false, zone.y + zone.h, abs(point.y - frame.minY)),
            ]
            for (isVertical, value, distance) in candidates {
                guard value > 0.001, value < 0.999, distance <= grabDistance else { continue }
                // Close to the line is not enough; stay within its span
                let inSpan = isVertical
                    ? (point.y >= frame.minY - grabDistance && point.y <= frame.maxY + grabDistance)
                    : (point.x >= frame.minX - grabDistance && point.x <= frame.maxX + grabDistance)
                guard inSpan else { continue }
                if best == nil || distance < best!.distance {
                    best = (Boundary(isVertical: isVertical, value: value), distance)
                }
            }
        }
        return best?.boundary
    }

    /// The boundary mirrored across the screen center, if there is one.
    private func mirror(of boundary: Boundary) -> Boundary? {
        let target = 1 - boundary.value
        guard abs(target - boundary.value) > epsilon else { return nil }
        for zone in zones {
            for value in [start(zone, boundary.isVertical), end(zone, boundary.isVertical)] {
                if abs(value - target) < epsilon {
                    return Boundary(isVertical: boundary.isVertical, value: value)
                }
            }
        }
        return nil
    }

    /// Moves a boundary, stretching the zones on both sides so no hole opens up.
    /// Returns where it actually landed, which minSize may cut short.
    @discardableResult
    private func moveBoundary(_ boundary: Boundary, to target: Double) -> Double {
        guard boundary.value > 0.001, boundary.value < 0.999 else { return boundary.value }
        let isVertical = boundary.isVertical
        var leading: [Int] = []   // zones that start at this boundary
        var trailing: [Int] = []  // zones that end at this boundary
        for (index, zone) in zones.enumerated() {
            if abs(start(zone, isVertical) - boundary.value) < epsilon { leading.append(index) }
            if abs(end(zone, isVertical) - boundary.value) < epsilon { trailing.append(index) }
        }
        guard !leading.isEmpty || !trailing.isEmpty else { return boundary.value }

        var lower = minSize
        var upper = 1 - minSize
        for index in leading { upper = min(upper, end(zones[index], isVertical) - minSize) }
        for index in trailing { lower = max(lower, start(zones[index], isVertical) + minSize) }
        guard lower <= upper else { return boundary.value }
        let value = target.clamped(to: lower...upper)

        for index in leading {
            let finish = end(zones[index], isVertical)
            if isVertical {
                zones[index].x = value
                zones[index].w = finish - value
            } else {
                zones[index].y = value
                zones[index].h = finish - value
            }
        }
        for index in trailing {
            if isVertical {
                zones[index].w = value - zones[index].x
            } else {
                zones[index].h = value - zones[index].y
            }
        }
        return value
    }

    /// Snaps to the other zones' boundaries and to the usual split points
    private func snap(_ value: Double, isVertical: Bool, ignoring current: Double) -> Double {
        var targets: [Double] = [1.0 / 4, 1.0 / 3, 1.0 / 2, 2.0 / 3, 3.0 / 4]
        for zone in zones {
            for candidate in [start(zone, isVertical), end(zone, isVertical)]
            where abs(candidate - current) > epsilon * 2 {
                targets.append(candidate)
            }
        }
        let nearest = targets.min { abs($0 - value) < abs($1 - value) }
        if let nearest, abs(nearest - value) < 0.012 { return nearest }
        return value
    }

    // MARK: - Split, merge, align

    /// Cuts a zone in two at the clicked point (for double-clicks)
    private func splitAtPoint(_ index: Int, point: NSPoint, isVertical: Bool) {
        let zone = zones[index]
        let raw = isVertical ? ratioX(point.x) : ratioY(point.y)
        let cut = snap(raw, isVertical: isVertical, ignoring: .infinity)
        let from = start(zone, isVertical)
        let to = end(zone, isVertical)
        guard cut - from >= minSize, to - cut >= minSize else { NSSound.beep(); return }

        pushHistory()
        var second = zone
        if isVertical {
            zones[index].w = cut - zone.x
            second.x = cut
            second.w = to - cut
        } else {
            zones[index].h = cut - zone.y
            second.y = cut
            second.h = to - cut
        }
        zones.insert(second, at: index + 1)
        selected = index
        needsDisplay = true
    }

    /// Cuts a zone into equal parts
    private func divide(_ index: Int, into count: Int, isVertical: Bool) {
        let zone = zones[index]
        let total = isVertical ? zone.w : zone.h
        let size = total / Double(count)
        guard size >= minSize else { NSSound.beep(); return }

        pushHistory()
        var pieces: [Zone] = []
        for step in 0..<count {
            var piece = zone
            if isVertical {
                piece.x = zone.x + size * Double(step)
                piece.w = size
            } else {
                piece.y = zone.y + size * Double(step)
                piece.h = size
            }
            pieces.append(piece)
        }
        zones.replaceSubrange(index...index, with: pieces)
        selected = index
        needsDisplay = true
    }

    /// Evens out zones that sit in a row, keeping the range they cover
    private func equalize(_ group: [Int], isVertical: Bool) {
        guard group.count >= 2 else { NSSound.beep(); return }
        pushHistory()
        let from = start(zones[group[0]], isVertical)
        let to = end(zones[group[group.count - 1]], isVertical)
        let size = (to - from) / Double(group.count)
        for (step, index) in group.enumerated() {
            let position = from + size * Double(step)
            if isVertical {
                zones[index].x = position
                zones[index].w = size
            } else {
                zones[index].y = position
                zones[index].h = size
            }
        }
        needsDisplay = true
    }

    /// Whether a zone can be centered. An edge on the screen border cannot
    /// move, so centering such a zone would tear a hole in the layout.
    private func canCenter(_ index: Int, isVertical: Bool) -> Bool {
        let zone = zones[index]
        let from = start(zone, isVertical)
        let to = end(zone, isVertical)
        guard from > 0.001, to < 0.999 else { return false }
        return abs((1 - (to - from)) / 2 - from) > epsilon
    }

    /// Moves a zone so it sits symmetrically about the screen's center line,
    /// keeping its size
    private func center(_ index: Int, isVertical: Bool) {
        guard canCenter(index, isVertical: isVertical) else { NSSound.beep(); return }
        let zone = zones[index]
        let size = isVertical ? zone.w : zone.h
        let newStart = (1 - size) / 2
        let newEnd = newStart + size
        let oldStart = start(zone, isVertical)
        let oldEnd = end(zone, isVertical)

        pushHistory()
        // Widening outward first keeps the move from hitting minSize midway
        if newStart < oldStart {
            moveBoundary(Boundary(isVertical: isVertical, value: oldStart), to: newStart)
            moveBoundary(Boundary(isVertical: isVertical, value: oldEnd), to: newEnd)
        } else {
            moveBoundary(Boundary(isVertical: isVertical, value: oldEnd), to: newEnd)
            moveBoundary(Boundary(isVertical: isVertical, value: oldStart), to: newStart)
        }
        needsDisplay = true
    }

    /// Zones in the same column (same x and w, stacked), limited to the run
    /// that contains the given index
    private func columnGroup(of index: Int) -> [Int] {
        let target = zones[index]
        let members = zones.indices
            .filter { abs(zones[$0].x - target.x) < epsilon && abs(zones[$0].w - target.w) < epsilon }
            .sorted { zones[$0].y < zones[$1].y }
        return contiguous(members, containing: index, isVertical: false)
    }

    /// Zones in the same row (same y and h, side by side)
    private func rowGroup(of index: Int) -> [Int] {
        let target = zones[index]
        let members = zones.indices
            .filter { abs(zones[$0].y - target.y) < epsilon && abs(zones[$0].h - target.h) < epsilon }
            .sorted { zones[$0].x < zones[$1].x }
        return contiguous(members, containing: index, isVertical: true)
    }

    /// Keeps only the uninterrupted run, so a same-width zone somewhere else
    /// does not get dragged in
    private func contiguous(_ members: [Int], containing index: Int, isVertical: Bool) -> [Int] {
        guard let position = members.firstIndex(of: index) else { return [index] }
        var first = position
        while first > 0,
              abs(end(zones[members[first - 1]], isVertical) - start(zones[members[first]], isVertical)) < epsilon {
            first -= 1
        }
        var last = position
        while last < members.count - 1,
              abs(end(zones[members[last]], isVertical) - start(zones[members[last + 1]], isVertical)) < epsilon {
            last += 1
        }
        return Array(members[first...last])
    }

    private func isMergeable(_ first: Int, _ second: Int) -> Bool {
        let a = zones[first]
        let b = zones[second]
        let sameColumn = abs(a.x - b.x) < epsilon && abs(a.w - b.w) < epsilon
        let sameRow = abs(a.y - b.y) < epsilon && abs(a.h - b.h) < epsilon
        let stacked = abs(a.y + a.h - b.y) < epsilon || abs(b.y + b.h - a.y) < epsilon
        let sideBySide = abs(a.x + a.w - b.x) < epsilon || abs(b.x + b.w - a.x) < epsilon
        return (sameColumn && stacked) || (sameRow && sideBySide)
    }

    private func merge(_ first: Int, _ second: Int) {
        let a = zones[first]
        let b = zones[second]
        var merged = a
        merged.x = min(a.x, b.x)
        merged.y = min(a.y, b.y)
        merged.w = max(a.x + a.w, b.x + b.w) - merged.x
        merged.h = max(a.y + a.h, b.y + b.h) - merged.y
        zones.remove(at: max(first, second))
        zones.remove(at: min(first, second))
        let insertAt = min(first, second)
        zones.insert(merged, at: insertAt)
        selected = insertAt
        needsDisplay = true
    }

    /// Merges the selected zone with a neighbour it forms a rectangle with
    private func mergeSelected() {
        guard let index = selected,
              let partner = zones.indices.first(where: { $0 != index && isMergeable(index, $0) })
        else { NSSound.beep(); return }
        pushHistory()
        merge(index, partner)
    }

    private func pushHistory() {
        history.append(zones)
        if history.count > 50 { history.removeFirst() }
    }

    // MARK: - Keyboard

    override func keyDown(with event: NSEvent) {
        let command = event.modifierFlags.contains(.command)
        switch event.keyCode {
        case 53:  // esc
            onCancel?()
        // Return is the Save button's key equivalent, so it is not handled here
        case 51, 117:  // delete
            mergeSelected()
        default:
            switch event.charactersIgnoringModifiers?.lowercased() {
            case "s" where command:
                save()
            case "z" where command:
                undoEdit()
            case "v":
                if let index = selected { divide(index, into: 2, isVertical: true) } else { NSSound.beep() }
            case "h":
                if let index = selected { divide(index, into: 2, isVertical: false) } else { NSSound.beep() }
            case "r":
                pushHistory()
                zones = Layout.default.zones
                needsDisplay = true
            default:
                super.keyDown(with: event)
            }
        }
    }

    @objc private func save() {
        onSave?()
    }

    @objc private func cancel() {
        onCancel?()
    }

    // MARK: - The panel

    /// Rebuilds the gap choices with the current value selected
    private func configureGapPopUp() {
        var choices: [Double] = [0, 2, 4, 8, 12, 16]
        if !choices.contains(where: { abs($0 - gap) < 0.01 }) {
            choices.append(gap)
            choices.sort()
        }
        gapChoices = choices
        gapPopUp.removeAllItems()
        for value in choices {
            gapPopUp.addItem(withTitle: value == 0 ? L("None") : "\(Layout.number(value)) pt")
        }
        if let index = choices.firstIndex(where: { abs($0 - gap) < 0.01 }) {
            gapPopUp.selectItem(at: index)
        }
    }

    @objc private func gapChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        guard gapChoices.indices.contains(index) else { return }
        gap = gapChoices[index]
        needsDisplay = true
    }

    /// Spells out what can be done, grouped by the kind of action
    private func addHUD() {
        let groups = [
            makeGroup(L("Split"), [
                L("Double-click a zone → cut it there"),
                L("Right-click → 2 or 3 parts, either way"),
            ]),
            makeGroup(L("Resize"), [
                L("Drag a boundary"),
                L("Hold ⌥ → mirrored about the screen center"),
            ]),
            makeGroup(L("Align"), [
                L("Right-click → distribute the column or row evenly"),
                L("Right-click → center on the screen"),
            ]),
            makeGroup(L("Merge"), [
                L("Press the Merge button on a boundary"),
                L("Shown only where the two form a rectangle"),
            ]),
        ]

        var hintViews: [NSView] = []
        for group in groups {
            if !hintViews.isEmpty { hintViews.append(makeSeparator()) }
            hintViews.append(group)
        }
        let hintRow = NSStackView(views: hintViews)
        hintRow.orientation = .horizontal
        hintRow.alignment = .top
        hintRow.spacing = 18

        // Top row: which screen is being edited, plus the controls.
        // Bottom row: the explanations. One row would run off narrow screens.
        let titleRow = makeTitleRow()
        let divider = NSBox()
        divider.boxType = .custom
        divider.borderWidth = 0
        divider.fillColor = NSColor.white.withAlphaComponent(0.18)

        let stack = NSStackView(views: [titleRow, divider, hintRow])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.edgeInsets = NSEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        NSLayoutConstraint.activate([
            titleRow.widthAnchor.constraint(equalTo: hintRow.widthAnchor),
            divider.widthAnchor.constraint(equalTo: hintRow.widthAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
        ])

        let panel = NSVisualEffectView()
        panel.material = .hudWindow
        panel.blendingMode = .withinWindow
        panel.state = .active
        panel.wantsLayer = true
        panel.layer?.cornerRadius = 16
        panel.layer?.borderWidth = 1
        panel.layer?.borderColor = NSColor.white.withAlphaComponent(0.22).cgColor
        panel.shadow = NSShadow()
        panel.layer?.shadowColor = NSColor.black.cgColor
        panel.layer?.shadowOpacity = 0.45
        panel.layer?.shadowRadius = 18
        panel.layer?.shadowOffset = CGSize(width: 0, height: -4)

        panel.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panel.topAnchor),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
        ])

        // Tighten up rather than run off a narrow screen
        if stack.fittingSize.width > bounds.width - 40 {
            stack.spacing = 10
            stack.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }

        let size = stack.fittingSize
        panel.frame = NSRect(
            x: (bounds.width - size.width) / 2, y: 32, width: size.width, height: size.height)
        panel.autoresizingMask = [.minXMargin, .maxXMargin, .maxYMargin]
        addSubview(panel)
    }

    /// A heading with its explanation lines
    private func makeGroup(_ title: String, _ lines: [String], isTitleAccented: Bool = false) -> NSView {
        let heading = NSTextField(labelWithString: title)
        heading.font = .systemFont(ofSize: 13, weight: .bold)
        heading.textColor = isTitleAccented ? .controlAccentColor : .white

        var views: [NSView] = [heading]
        for line in lines {
            let label = NSTextField(labelWithString: line)
            label.font = .systemFont(ofSize: 12)
            label.textColor = NSColor.white.withAlphaComponent(0.72)
            views.append(label)
        }

        let stack = NSStackView(views: views)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 3
        return stack
    }

    private func makeSeparator() -> NSView {
        let separator = NSBox()
        separator.boxType = .custom
        separator.borderWidth = 0
        separator.fillColor = NSColor.white.withAlphaComponent(0.18)
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return separator
    }

    /// The top row: the display being edited, the gap, and the buttons.
    private func makeTitleRow() -> NSView {
        let name = NSTextField(
            labelWithString: displayName.isEmpty ? L("This display") : displayName)
        name.font = .systemFont(ofSize: 14, weight: .bold)
        name.textColor = .controlAccentColor

        let note = NSTextField(labelWithString: savesEveryDisplay
            ? L("Editing this screen\u{2019}s layout (saving covers every display)")
            : L("Editing this screen\u{2019}s layout"))
        note.font = .systemFont(ofSize: 12)
        note.textColor = NSColor.white.withAlphaComponent(0.72)

        let spacer = NSView()
        spacer.setContentHuggingPriority(.init(1), for: .horizontal)

        let gapLabel = NSTextField(labelWithString: L("Gap"))
        gapLabel.font = .systemFont(ofSize: 13, weight: .bold)
        gapLabel.textColor = .white
        configureGapPopUp()
        gapPopUp.target = self
        gapPopUp.action = #selector(gapChanged(_:))

        let cancelButton = NSButton(title: L("Cancel"), target: self, action: #selector(cancel))
        let saveButton = NSButton(title: L("Save"), target: self, action: #selector(save))
        saveButton.keyEquivalent = "\r"
        for button in [cancelButton, saveButton] { button.controlSize = .large }

        let row = NSStackView(views: [
            name, note, spacer, gapLabel, gapPopUp, cancelButton, saveButton,
        ])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10
        return row
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
