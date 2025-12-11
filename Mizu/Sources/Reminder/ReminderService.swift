import Foundation
import os.log

actor ReminderService {
    private var reminderTask: Task<Void, Never>?
    private let notificationActor = NotificationActor.shared
    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "ReminderService")

    func startReminder(interval: ReminderInterval, soundEnabled: Bool) {
        stopReminder()
        logger.info("Starting reminder with interval: \(interval.displayString)")
        reminderTask = createReminderTask(interval: interval, soundEnabled: soundEnabled)
    }

    func stopReminder() {
        guard reminderTask != nil else { return }
        logger.info("Stopping reminder")
        reminderTask?.cancel()
        reminderTask = nil
    }

    func resetReminder(interval: ReminderInterval, soundEnabled: Bool) {
        logger.info("Resetting reminder with interval: \(interval.displayString)")
        startReminder(interval: interval, soundEnabled: soundEnabled)
    }

    private func createReminderTask(interval: ReminderInterval, soundEnabled: Bool) -> Task<Void, Never> {
        Task { [weak self] in
            await self?.runReminderLoop(interval: interval, soundEnabled: soundEnabled)
        }
    }

    private func runReminderLoop(interval: ReminderInterval, soundEnabled: Bool) async {
        while !Task.isCancelled {
            let shouldContinue = await waitAndNotify(interval: interval, soundEnabled: soundEnabled)
            if !shouldContinue { break }
        }
    }

    private func waitAndNotify(interval: ReminderInterval, soundEnabled: Bool) async -> Bool {
        do {
            try await Task.sleep(for: .seconds(interval.seconds))
            guard !Task.isCancelled else {
                logger.info("Reminder task cancelled during sleep")
                return false
            }
            await deliverWaterReminder(interval: interval, soundEnabled: soundEnabled)
            return true
        } catch {
            logger.info("Reminder task cancelled")
            return false
        }
    }

    private func deliverWaterReminder(interval: ReminderInterval, soundEnabled: Bool) async {
        await notificationActor.deliverNotification(
            title: "Time to drink water",
            body: "It's been \(interval.displayString) since your last glass.",
            withSound: soundEnabled
        )
    }
}
