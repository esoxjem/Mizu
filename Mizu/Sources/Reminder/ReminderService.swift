import Foundation
import os.log

/// Actor that manages the reminder timer using Swift Concurrency.
/// Replaces Timer.scheduledTimer with Task.sleep for modern async/await handling.
actor ReminderService {
    private var reminderTask: Task<Void, Never>?
    private let notificationActor = NotificationActor.shared
    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "ReminderService")

    /// Starts the reminder timer with the specified interval.
    /// - Parameters:
    ///   - interval: The reminder interval
    ///   - soundEnabled: Whether to play sound with notifications
    func startReminder(interval: ReminderInterval, soundEnabled: Bool) {
        stopReminder()

        logger.info("Starting reminder with interval: \(interval.displayString)")

        reminderTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(interval.seconds))

                    guard !Task.isCancelled else {
                        self?.logger.info("Reminder task cancelled during sleep")
                        break
                    }

                    await self?.notificationActor.deliverNotification(
                        title: "Time to drink water",
                        body: "It's been \(interval.displayString) since your last glass.",
                        withSound: soundEnabled
                    )
                } catch {
                    // Task was cancelled during sleep
                    self?.logger.info("Reminder task cancelled")
                    break
                }
            }
        }
    }

    /// Stops the current reminder timer.
    func stopReminder() {
        if reminderTask != nil {
            logger.info("Stopping reminder")
            reminderTask?.cancel()
            reminderTask = nil
        }
    }

    /// Resets the reminder timer with new settings.
    /// - Parameters:
    ///   - interval: The new reminder interval
    ///   - soundEnabled: Whether to play sound with notifications
    func resetReminder(interval: ReminderInterval, soundEnabled: Bool) {
        logger.info("Resetting reminder with interval: \(interval.displayString)")
        startReminder(interval: interval, soundEnabled: soundEnabled)
    }
}
