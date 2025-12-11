import Foundation
import Sparkle
import os.log

final class GentleUpdateReminderDelegate: NSObject, SPUStandardUserDriverDelegate {
    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "GentleUpdateReminder")
    private let updateState: UpdateAvailabilityState
    private let notificationActor: NotificationActor

    var supportsGentleScheduledUpdateReminders: Bool { true }

    init(updateState: UpdateAvailabilityState, notificationActor: NotificationActor) {
        self.updateState = updateState
        self.notificationActor = notificationActor
        super.init()
    }

    func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        let sparkleHandlesIt = immediateFocus
        logger.info("Sparkle handles showing update: \(sparkleHandlesIt) (immediateFocus: \(immediateFocus))")
        return sparkleHandlesIt
    }

    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem,
        state: SPUUserUpdateState
    ) {
        logger.info("Will handle showing update - handleShowingUpdate: \(handleShowingUpdate), userInitiated: \(state.userInitiated)")

        guard !handleShowingUpdate else { return }
        guard !state.userInitiated else { return }

        logger.info("Showing gentle reminder for version \(update.displayVersionString)")

        Task { @MainActor in
            updateState.setUpdateAvailable(version: update.displayVersionString)
        }

        Task {
            await notificationActor.deliverUpdateAvailableNotification(version: update.displayVersionString)
        }
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        logger.info("User gave attention to update: \(update.displayVersionString)")
    }

    func standardUserDriverWillFinishUpdateSession() {
        logger.info("Update session finishing, clearing state")
        Task { @MainActor in
            updateState.clearPendingUpdate()
        }
    }
}
