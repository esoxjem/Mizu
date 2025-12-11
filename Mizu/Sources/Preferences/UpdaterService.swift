import Foundation
import Sparkle
import Combine
import os.log

final class UpdaterDelegate: NSObject, SPUUpdaterDelegate {
    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "Updater")

    func updater(_ updater: SPUUpdater, didAbortWithError error: any Error) {
        logger.error("Update aborted: \(error.localizedDescription)")
    }

    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        logger.info("Appcast loaded with \(appcast.items.count) items")
    }

    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        logger.info("No update available")
    }

    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        logger.info("Found update: \(item.displayVersionString) (build \(item.versionString))")
    }

    func updater(_ updater: SPUUpdater, didDownloadUpdate item: SUAppcastItem) {
        logger.info("Downloaded update: \(item.displayVersionString)")
    }

    func updater(_ updater: SPUUpdater, willInstallUpdate item: SUAppcastItem) {
        logger.info("Installing update: \(item.displayVersionString)")
    }
}

@MainActor
final class UpdaterService: ObservableObject {
    static let shared = UpdaterService()

    @Published private(set) var canCheckForUpdates = false

    let updateAvailabilityState = UpdateAvailabilityState.shared

    private let updaterController: SPUStandardUpdaterController
    private let updaterDelegate = UpdaterDelegate()
    private let gentleReminderDelegate: GentleUpdateReminderDelegate
    private var cancellable: AnyCancellable?

    private init() {
        gentleReminderDelegate = GentleUpdateReminderDelegate(
            updateState: UpdateAvailabilityState.shared,
            notificationActor: NotificationActor.shared
        )

        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: updaterDelegate,
            userDriverDelegate: gentleReminderDelegate
        )
        bindCanCheckForUpdates()
    }

    private func bindCanCheckForUpdates() {
        cancellable = updaterController.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .assign(to: \.canCheckForUpdates, on: self)
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }

    func installPendingUpdate() {
        updaterController.checkForUpdates(nil)
    }

    var automaticallyChecksForUpdates: Bool {
        get { updaterController.updater.automaticallyChecksForUpdates }
        set { updaterController.updater.automaticallyChecksForUpdates = newValue }
    }
}
