import AppKit

/// A small window for editing layout.json in place, so that opening the
/// settings never hands the file to whatever app happens to own .json.
/// The file itself is unchanged, so any external editor still works.
final class LayoutEditor: NSWindowController, NSWindowDelegate, NSTextViewDelegate {
    private let store: LayoutStore
    private let textView = NSTextView()
    private let statusLabel = NSTextField(labelWithString: "")
    /// The text as last written to disk, to tell whether there are edits
    private var savedText = ""

    init(store: LayoutStore) {
        self.store = store
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 460),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = L("Waridake Layout")
        // The proxy icon in the title bar can be dragged to Finder or an editor
        window.representedURL = store.url
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("LayoutEditor")
        super.init(window: window)
        window.delegate = self
        window.contentView = makeContentView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unused") }

    func show() {
        // Reopening an already open window must not discard edits in progress
        if window?.isVisible != true { revertToFile() }
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window?.makeFirstResponder(textView)
    }

    /// Follows a save made in the visual editor, without touching edits here.
    func refreshIfUnchanged() {
        guard window?.isVisible == true, textView.string == savedText else { return }
        revertToFile()
    }

    // MARK: - Building

    private func makeContentView() -> NSView {
        textView.isRichText = false
        // Smart quotes and dashes would silently break the JSON
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textContainerInset = NSSize(width: 6, height: 8)
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.delegate = self

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        scrollView.borderType = .noBorder
        scrollView.setContentHuggingPriority(.init(1), for: .vertical)

        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.lineBreakMode = .byTruncatingTail
        statusLabel.setContentHuggingPriority(.init(1), for: .horizontal)
        statusLabel.setContentCompressionResistancePriority(.init(1), for: .horizontal)

        let resetButton = NSButton(
            title: L("Restore Default"), target: self, action: #selector(resetToDefault))
        let saveButton = NSButton(
            title: L("Save"), target: self, action: #selector(saveDocument(_:)))
        // Also on the button, so saving works even if the menu shortcut does not
        saveButton.keyEquivalent = "s"
        saveButton.keyEquivalentModifierMask = .command

        let bottomBar = NSStackView(views: [statusLabel, resetButton, saveButton])
        bottomBar.orientation = .horizontal
        bottomBar.spacing = 8
        bottomBar.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 10, right: 12)
        bottomBar.setHuggingPriority(.required, for: .vertical)

        let separator = NSBox()
        separator.boxType = .separator

        let container = NSStackView(views: [scrollView, separator, bottomBar])
        container.orientation = .vertical
        container.spacing = 0
        container.distribution = .fill
        return container
    }

    // MARK: - Actions

    @objc func saveDocument(_ sender: Any?) {
        _ = saveIfValid()
    }

    @discardableResult
    private func saveIfValid() -> Bool {
        let text = textView.string
        if let message = store.save(text: text) {
            status(message, isError: true)
            NSSound.beep()
            return false
        }
        savedText = text
        let displays = store.set.displays.count
        let detail = displays == 0
            ? L("%d zones", store.set.base.zones.count)
            : L("%d default zones + %d display(s)", store.set.base.zones.count, displays)
        status(L("Saved (%@). Takes effect on the next drag.", detail), isError: false)
        return true
    }

    @objc private func resetToDefault() {
        textView.string = Layout.defaultText
        status(L("Back to the default layout. Save to apply it."), isError: false)
    }

    private func revertToFile() {
        savedText = store.currentText()
        textView.string = savedText
        status(store.url.path, isError: false)
    }

    private func status(_ message: String, isError: Bool) {
        statusLabel.stringValue = isError ? "⚠️ \(message)" : message
        statusLabel.textColor = isError ? .systemRed : .secondaryLabelColor
        statusLabel.toolTip = message
    }

    // MARK: - Delegates

    func textDidChange(_ notification: Notification) {
        guard textView.string != savedText else { return }
        status(L("Unsaved changes (⌘S to save)"), isError: false)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard textView.string != savedText else { return true }
        let alert = NSAlert()
        alert.messageText = L("There are unsaved changes")
        alert.informativeText = L("Closing the window discards them.")
        alert.addButton(withTitle: L("Save and Close"))
        alert.addButton(withTitle: L("Discard and Close"))
        alert.addButton(withTitle: L("Cancel"))
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            return saveIfValid()  // stay open if saving fails
        case .alertSecondButtonReturn:
            return true
        default:
            return false
        }
    }
}
