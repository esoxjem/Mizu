import AppKit
import SwiftUI

/// Unified controller for the menu bar status item and popover.
/// Combines the responsibilities of MenuBar and MenuBarPresenter into a single @MainActor class.
@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private let settings = AppSettings.shared
    private let reminderService = ReminderService()
    private var eventMonitor: Any?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        setupStatusBarButton()
        setupPopover()
        setupEventMonitor()
        startReminder()
    }

    // MARK: - Setup

    private func setupStatusBarButton() {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarImage"))
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        let hostingController = PreferencesHostingController(
            settings: settings,
            onIntervalChanged: { [weak self] in
                self?.resetReminder()
            }
        )
        popover.contentViewController = hostingController
        popover.behavior = .transient
    }

    private func setupEventMonitor() {
        // Monitor for clicks outside the popover to close it
        // The .transient behavior should handle most cases, but this ensures
        // consistent behavior with the original implementation
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.popover.close()
            }
        }
    }

    // MARK: - Actions

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.close()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    // MARK: - Reminder Management

    private func startReminder() {
        Task {
            await reminderService.startReminder(
                interval: settings.selectedInterval,
                soundEnabled: settings.isSoundEnabled
            )
        }
    }

    private func resetReminder() {
        Task {
            await reminderService.resetReminder(
                interval: settings.selectedInterval,
                soundEnabled: settings.isSoundEnabled
            )
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
