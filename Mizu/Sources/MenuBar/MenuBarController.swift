import AppKit
import SwiftUI

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private let settings = AppSettings.shared
    private let reminderService = ReminderService()
    private var clickOutsideMonitor: Any?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        configureStatusBarButton()
        configurePopover()
        monitorClicksOutsidePopover()
        startReminder()
    }

    private func configureStatusBarButton() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(named: NSImage.Name("StatusBarImage"))
        button.action = #selector(togglePopover)
        button.target = self
    }

    private func configurePopover() {
        popover.contentViewController = PreferencesHostingController(
            settings: settings,
            onIntervalChanged: { [weak self] in self?.resetReminder() }
        )
        popover.behavior = .transient
    }

    private func monitorClicksOutsidePopover() {
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown],
            handler: { [weak self] _ in self?.closePopoverIfVisible() }
        )
    }

    private func closePopoverIfVisible() {
        guard popover.isShown else { return }
        popover.close()
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.close()
        } else {
            showPopover(relativeTo: button)
        }
    }

    private func showPopover(relativeTo button: NSStatusBarButton) {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        makePopoverKeyWindow()
    }

    private func makePopoverKeyWindow() {
        popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
    }

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
        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
