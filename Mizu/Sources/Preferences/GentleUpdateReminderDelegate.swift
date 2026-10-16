import Foundation
import Sparkle
import os.log

final class GentleUpdateReminderDelegate: NSObject, SPUStandardUserDriverDelegate {
    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "GentleUpdateReminder")
    private let notifyUpdate: (String) async -> Void
    @MainActor var onUpdateAvailable: ((String) -> Void)?
    @MainActor var onSessionFinished: (() -> Void)?

    var supportsGentleScheduledUpdateReminders: Bool { true }

    init(
        notifyUpdate: @escaping (String) async -> Void = { version in
            await NotificationActor.shared.deliverUpdateAvailableNotification(version: version)
        }
    ) {
        self.notifyUpdate = notifyUpdate
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
            onUpdateAvailable?(update.displayVersionString)
        }

        Task {
            await notifyUpdate(update.displayVersionString)
        }
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        logger.info("User gave attention to update: \(update.displayVersionString)")
    }

    func standardUserDriverWillFinishUpdateSession() {
        logger.info("Update session finishing, clearing state")
        Task { @MainActor in
            onSessionFinished?()
        }
    }
}
