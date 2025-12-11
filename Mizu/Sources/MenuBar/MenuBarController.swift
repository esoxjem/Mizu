import AppKit
import SwiftUI
import Combine

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private let settings = AppSettings.shared
    private let reminderService = ReminderService()
    private let updateState = UpdateAvailabilityState.shared
    private var clickOutsideMonitor: Any?
    private var updateStateCancellable: AnyCancellable?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        configureStatusBarButton()
        configurePopover()
        monitorClicksOutsidePopover()
        startReminder()
        observeUpdateAvailability()
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

    private func observeUpdateAvailability() {
        updateStateCancellable = updateState.$isUpdateAvailable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                self?.updateBadgeVisibility(showBadge: isAvailable)
            }
    }

    private func updateBadgeVisibility(showBadge: Bool) {
        guard let button = statusItem.button else { return }

        if showBadge {
            button.image = createBadgedStatusBarImage()
        } else {
            button.image = NSImage(named: NSImage.Name("StatusBarImage"))
        }
    }

    private func createBadgedStatusBarImage() -> NSImage? {
        guard let baseImage = NSImage(named: NSImage.Name("StatusBarImage")) else {
            return nil
        }

        let badgeSize: CGFloat = 6
        let imageSize = baseImage.size

        let compositeImage = NSImage(size: imageSize, flipped: false) { rect in
            baseImage.draw(in: rect)

            let badgeRect = NSRect(
                x: imageSize.width - badgeSize - 1,
                y: imageSize.height - badgeSize - 1,
                width: badgeSize,
                height: badgeSize
            )

            NSColor.systemRed.setFill()
            NSBezierPath(ovalIn: badgeRect).fill()

            return true
        }

        compositeImage.isTemplate = true
        return compositeImage
    }

    deinit {
        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
        }
        updateStateCancellable?.cancel()
    }
}
