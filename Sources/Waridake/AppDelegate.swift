import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var dragMonitor: DragMonitor!
    private let layoutStore = LayoutStore()
    private var editor: LayoutEditor?
    private var zoneEditor: ZoneEditor?
    private var list: LayoutList?
    /// The menu's Enabled state, kept apart from the pause during editing
    private var enabledByUser = true
    /// Shown only while accessibility is missing (separator included)
    private var axSeparator: NSMenuItem!
    private var axItem: NSMenuItem!
    private var axTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let trusted = AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)

        layoutStore.loadOrCreate()
        let store = layoutStore
        dragMonitor = DragMonitor { store.layout(for: $0) }
        dragMonitor.start()
        setupMainMenu()
        setupStatusItem()
        showAXWarning(!trusted)
        // Permission is usually granted while we run, so watch for it
        if !trusted { startWatchingAXTrust() }
    }

    /// Once permission arrives, re-register the monitors and drop the warning.
    /// Checking only at launch would leave the app claiming to be untrusted
    /// long after the user granted access.
    private func startWatchingAXTrust() {
        axTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard AXIsProcessTrusted() else { return }
            timer.invalidate()
            guard let self else { return }
            self.axTimer = nil
            self.dragMonitor.restart()
            self.showAXWarning(false)
        }
    }

    private func showAXWarning(_ show: Bool) {
        axSeparator.isHidden = !show
        axItem.isHidden = !show
    }

    /// This app is an LSUIElement, so the menu bar never shows. The main menu
    /// still has to exist: without it not even ⌘C/⌘V or ⌘Z work in the JSON
    /// editor, because key equivalents are resolved through it.
    private func setupMainMenu() {
        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: L("Close"), action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        appMenu.addItem(
            withTitle: L("Quit Waridake"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let editMenu = NSMenu(title: L("Edit"))
        editMenu.addItem(withTitle: L("Undo"), action: Selector(("undo:")), keyEquivalent: "z")
        let redoItem = editMenu.addItem(
            withTitle: L("Redo"), action: Selector(("redo:")), keyEquivalent: "z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: L("Cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: L("Copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: L("Paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(
            withTitle: L("Select All"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        let mainMenu = NSMenu()
        for submenu in [appMenu, editMenu] {
            let item = NSMenuItem()
            item.submenu = submenu
            mainMenu.addItem(item)
        }
        NSApp.mainMenu = mainMenu
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "rectangle.split.3x1",
            accessibilityDescription: "Waridake")

        let menu = NSMenu()

        let enabledItem = NSMenuItem(title: L("Enabled"), action: #selector(toggleEnabled(_:)), keyEquivalent: "")
        enabledItem.target = self
        enabledItem.state = .on
        menu.addItem(enabledItem)

        menu.addItem(.separator())

        let arrangeItem = NSMenuItem(
            title: L("Arrange Open Windows"), action: #selector(arrangeWindows), keyEquivalent: "")
        arrangeItem.target = self
        menu.addItem(arrangeItem)

        menu.addItem(.separator())

        let reloadItem = NSMenuItem(
            title: L("Reload Layout"), action: #selector(reloadLayout), keyEquivalent: "r")
        reloadItem.target = self
        menu.addItem(reloadItem)

        let zoneItem = NSMenuItem(
            title: L("Edit Layout…"), action: #selector(editZones), keyEquivalent: "")
        zoneItem.target = self
        menu.addItem(zoneItem)

        let listItem = NSMenuItem(title: L("Layouts…"), action: #selector(showList), keyEquivalent: "")
        listItem.target = self
        menu.addItem(listItem)

        let editItem = NSMenuItem(title: L("Edit as JSON…"), action: #selector(editJSON), keyEquivalent: "")
        editItem.target = self
        menu.addItem(editItem)

        axSeparator = .separator()
        menu.addItem(axSeparator)
        axItem = NSMenuItem(
            title: L("⚠️ Accessibility not granted (click to open settings)"),
            action: #selector(openAccessibilitySettings), keyEquivalent: "")
        axItem.target = self
        menu.addItem(axItem)

        menu.addItem(.separator())
        let quitItem = NSMenuItem(
            title: L("Quit Waridake"), action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleEnabled(_ sender: NSMenuItem) {
        enabledByUser.toggle()
        dragMonitor.isEnabled = enabledByUser
        sender.state = enabledByUser ? .on : .off
    }

    @objc private func reloadLayout() {
        if !layoutStore.load() {
            let alert = NSAlert()
            alert.messageText = L("Could not read layout.json")
            alert.informativeText = L(
                "Check the JSON syntax. The previous layout stays in effect.\n%@",
                layoutStore.url.path)
            alert.runModal()
        }
    }

    /// Puts every open window back into the zone nearest to it
    @objc private func arrangeWindows() {
        guard AXIsProcessTrusted() else {
            openAccessibilitySettings()
            return
        }
        let moved = Arranger.arrangeAll { [layoutStore] screen in layoutStore.layout(for: screen) }
        if moved == 0 { NSSound.beep() }
    }

    @objc private func editZones() {
        if zoneEditor == nil {
            zoneEditor = ZoneEditor(store: layoutStore) { [weak self] editing in
                // Pause snapping while editing, so the two do not fight
                self?.dragMonitor.isEnabled = editing ? false : self?.enabledByUser ?? true
                if !editing { self?.editor?.refreshIfUnchanged() }
            }
        }
        zoneEditor?.show()
    }

    @objc private func showList() {
        if list == nil {
            list = LayoutList(store: layoutStore) { [weak self] in self?.editor?.refreshIfUnchanged() }
        }
        list?.show()
    }

    @objc private func editJSON() {
        if editor == nil { editor = LayoutEditor(store: layoutStore) }
        editor?.show()
    }

    @objc private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
