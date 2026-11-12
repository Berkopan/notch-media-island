import AppKit
import SwiftUI

@main
struct MacBookIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}

private final class IslandPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let state = IslandState()
    private let media = MediaService()
    private var panel: IslandPanel?
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var exitTime: Date?
    private var screen: NSScreen?
    private var hidden = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let panel = IslandPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .statusBar + 1
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.contentView = NSHostingView(rootView: IslandView(state: state, media: media))
        self.panel = panel
        positionPanel()
        setupMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(positionPanel), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(wake), name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleep), name: NSWorkspace.willSleepNotification, object: nil)
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateHover() }
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
        media.start()
    }

    @objc private func positionPanel() {
        screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main
        guard let screen, let panel else { return }
        state.notchHeight = max(28, screen.safeAreaInsets.top)
        if let left = screen.auxiliaryTopLeftArea, let right = screen.auxiliaryTopRightArea {
            state.notchWidth = max(160, right.minX - left.maxX + 4)
        } else { state.notchWidth = 190 }
        state.expanded = false
        panel.setFrame(NSRect(x: screen.frame.midX - (state.width + 40) / 2,
                              y: screen.frame.maxY - state.height - 30,
                              width: state.width + 40, height: state.height + 30), display: true)
        if !hidden { panel.orderFrontRegardless() }
    }

    private func updateHover() {
        guard !hidden, let screen, let panel else { return }
        let width = state.expanded ? state.width : state.notchWidth
        let height = state.expanded ? state.height : state.notchHeight + 4
        let region = NSRect(x: screen.frame.midX - width / 2, y: screen.frame.maxY - height, width: width, height: height)
        let inside = region.contains(NSEvent.mouseLocation)
        // Transparent margins must never swallow clicks intended for other apps.
        panel.ignoresMouseEvents = !inside && !state.scrubbing
        if inside || state.scrubbing {
            exitTime = nil
            if !state.expanded { state.expanded = true }
        } else if state.expanded {
            if exitTime == nil { exitTime = Date() }
            if Date().timeIntervalSince(exitTime!) > 0.35 { state.expanded = false; exitTime = nil }
        }
    }

    private func setupMenu() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "MacBook Island")
        let menu = NSMenu()
        let heading = NSMenuItem(title: "MacBook Island", action: nil, keyEquivalent: "")
        heading.isEnabled = false
        menu.addItem(heading)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Adayı gizle / göster", action: #selector(toggleVisible), keyEquivalent: "")
        menu.addItem(withTitle: "Medya bağlantısını yenile", action: #selector(reconnect), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Çıkış", action: #selector(quit), keyEquivalent: "q")
        for entry in menu.items where entry.action != nil { entry.target = self }
        item.menu = menu
        statusItem = item
    }

    @objc private func toggleVisible() {
        hidden.toggle()
        state.expanded = false
        if hidden { panel?.orderOut(nil) } else { positionPanel() }
    }
    @objc private func reconnect() { media.start() }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func sleep() { media.stop() }
    @objc private func wake() { positionPanel(); media.start() }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        media.stop()
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
