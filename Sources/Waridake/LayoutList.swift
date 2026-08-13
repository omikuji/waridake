import AppKit

/// The list of per-display layouts and of past versions. Used to drop the
/// settings of displays no longer in use, and to go back to an earlier state.
final class LayoutList: NSWindowController {
    private let store: LayoutStore
    /// Reports that the list changed the settings
    private let onChange: () -> Void
    private let content = FlippedStackView()

    init(store: LayoutStore, onChange: @escaping () -> Void) {
        self.store = store
        self.onChange = onChange
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 940, height: 470),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = L("Layouts")
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 940, height: 320)
        window.setFrameAutosaveName("LayoutList")
        window.center()
        super.init(window: window)

        content.orientation = .vertical
        content.alignment = .leading
        content.spacing = 10
        content.edgeInsets = NSEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.documentView = content
        content.translatesAutoresizingMaskIntoConstraints = false
        if let clip = content.superview {
            NSLayoutConstraint.activate([
                content.leadingAnchor.constraint(equalTo: clip.leadingAnchor),
                content.trailingAnchor.constraint(equalTo: clip.trailingAnchor),
                content.topAnchor.constraint(equalTo: clip.topAnchor),
            ])
        }
        window.contentView = scrollView
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unused") }

    func show() {
        reload()
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
    }

    // MARK: - Contents

    private func reload() {
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let connected = Set(NSScreen.screens.map(Display.key(for:)))
        content.addArrangedSubview(makeHeading(L("Per-display layouts")))
        content.addArrangedSubview(
            makeColumnTitles(L("Display"), L("Status"), L("Layout"), L("Last used")))

        content.addArrangedSubview(makeRow(
            title: L("Default"),
            subtitle: "—",
            detail: describe(store.set.base),
            note: L("for unlisted displays")))

        let keys = store.set.displays.keys.sorted { first, second in
            let a = store.set.displays[first]?.usedAt ?? .distantPast
            let b = store.set.displays[second]?.usedAt ?? .distantPast
            return a > b
        }
        if keys.isEmpty {
            content.addArrangedSubview(makeNote(L("No per-display layouts yet.")))
        }
        for key in keys {
            guard let entry = store.set.displays[key] else { continue }
            let isConnected = connected.contains(key)
            content.addArrangedSubview(makeRow(
                title: entry.name.isEmpty ? key : entry.name,
                subtitle: isConnected ? L("Connected") : L("Not connected"),
                detail: describe(entry.layout),
                note: entry.usedAt.map(Self.display.string(from:)) ?? L("no record"),
                actions: [
                    (L("Make Default"), { [weak self] in
                        self?.confirmMakeDefault(key: key, name: entry.name)
                    }),
                    (L("Delete"), { [weak self] in
                        self?.confirmDelete(key: key, name: entry.name)
                    }),
                ]))
        }

        content.addArrangedSubview(makeSpacer())
        content.addArrangedSubview(makeHeading(L("Edit history (last %d)", LayoutStore.historyLimit)))
        content.addArrangedSubview(makeColumnTitles(L("Saved at"), "", L("Layout"), ""))
        let snapshots = store.snapshots()
        if snapshots.isEmpty {
            content.addArrangedSubview(
                makeNote(L("No history yet. Every save keeps the previous state here.")))
        }
        for snapshot in snapshots {
            content.addArrangedSubview(makeRow(
                title: Self.display.string(from: snapshot.date),
                subtitle: "",
                detail: summarize(snapshot),
                note: "",
                actions: [(L("Restore"), { [weak self] in self?.confirmRestore(snapshot) })]))
        }
    }

    private func describe(_ layout: Layout) -> String {
        L("%d zones · gap %@", layout.zones.count,
          layout.gap == 0 ? L("none") : "\(Layout.number(layout.gap)) pt")
    }

    private func summarize(_ snapshot: LayoutStore.Snapshot) -> String {
        guard let data = try? Data(contentsOf: snapshot.url),
              let set = try? JSONDecoder().decode(LayoutSet.self, from: data) else {
            return L("unreadable")
        }
        return L("%d default zones · %d displays", set.base.zones.count, set.displays.count)
    }

    // MARK: - Actions

    private func confirmMakeDefault(key: String, name: String) {
        let alert = NSAlert()
        alert.messageText = L("Use the layout of \u{201C}%@\u{201D} as the default?", name.isEmpty ? key : name)
        alert.informativeText = L(
            "Displays without a layout of their own start from the default. "
            + "The current default is kept in the edit history.")
        alert.addButton(withTitle: L("Make Default"))
        alert.addButton(withTitle: L("Cancel"))
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        apply(store.makeDefault(key: key))
    }

    private func confirmDelete(key: String, name: String) {
        let alert = NSAlert()
        alert.messageText = L("Delete the layout for \u{201C}%@\u{201D}?", name.isEmpty ? key : name)
        alert.informativeText = L(
            "If this display is connected again, the default layout is used. "
            + "The state before deleting stays in the edit history.")
        alert.addButton(withTitle: L("Delete"))
        alert.addButton(withTitle: L("Cancel"))
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        apply(store.removeDisplay(key: key))
    }

    private func confirmRestore(_ snapshot: LayoutStore.Snapshot) {
        let alert = NSAlert()
        alert.messageText = L("Go back to the state from %@?", Self.display.string(from: snapshot.date))
        alert.informativeText = L("The current state is kept in history, so this can be undone.")
        alert.addButton(withTitle: L("Restore"))
        alert.addButton(withTitle: L("Cancel"))
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        apply(store.restore(snapshot))
    }

    private func apply(_ message: String?) {
        if let message {
            let alert = NSAlert()
            alert.messageText = L("That did not work")
            alert.informativeText = message
            alert.runModal()
            return
        }
        onChange()
        reload()
    }

    // MARK: - Pieces

    private static let display: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    private func makeHeading(_ text: String) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .bold)
        return label
    }

    private func makeNote(_ text: String) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabelColor
        return label
    }

    /// The row naming what each column holds
    private func makeColumnTitles(_ titles: String...) -> NSView {
        let widths: [CGFloat] = [200, 110, 190, 150]
        var views: [NSView] = []
        for (index, title) in titles.enumerated() {
            let label = NSTextField(labelWithString: title)
            label.font = .systemFont(ofSize: 11)
            label.textColor = .tertiaryLabelColor
            if index < widths.count {
                label.widthAnchor.constraint(equalToConstant: widths[index]).isActive = true
            }
            views.append(label)
        }
        let row = NSStackView(views: views)
        row.orientation = .horizontal
        row.spacing = 10
        return row
    }

    private func makeSpacer() -> NSView {
        let spacer = NSView()
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return spacer
    }

    private func makeRow(
        title: String, subtitle: String, detail: String, note: String,
        actions: [(title: String, handler: () -> Void)] = []
    ) -> NSView {
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true

        let subtitleLabel = NSTextField(labelWithString: subtitle)
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = subtitle == L("Connected") ? .systemGreen : .secondaryLabelColor
        subtitleLabel.widthAnchor.constraint(equalToConstant: 110).isActive = true

        let detailLabel = NSTextField(labelWithString: detail)
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabelColor
        detailLabel.widthAnchor.constraint(equalToConstant: 190).isActive = true

        let noteLabel = NSTextField(labelWithString: note)
        noteLabel.font = .systemFont(ofSize: 12)
        noteLabel.textColor = .secondaryLabelColor
        noteLabel.lineBreakMode = .byTruncatingTail
        noteLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true

        // Fixed column widths line the buttons up without a spacer
        var views: [NSView] = [titleLabel, subtitleLabel, detailLabel, noteLabel]
        for action in actions {
            views.append(ActionButton(title: action.title, handler: action.handler))
        }

        let row = NSStackView(views: views)
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10
        return row
    }
}

/// Stacks its rows from the top; a plain stack view would start at the bottom
private final class FlippedStackView: NSStackView {
    override var isFlipped: Bool { true }
}

/// A button that calls a closure, since every row acts on a different thing
private final class ActionButton: NSButton {
    private let handler: () -> Void

    init(title: String, handler: @escaping () -> Void) {
        self.handler = handler
        super.init(frame: .zero)
        self.title = title
        self.bezelStyle = .rounded
        self.target = self
        self.action = #selector(fire)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unused") }

    @objc private func fire() { handler() }
}
