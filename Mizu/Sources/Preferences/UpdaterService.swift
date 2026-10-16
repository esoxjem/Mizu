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
    #if DEBUG
    static let shared = UpdaterService(updatesEnabled: false)
    #else
    static let shared = UpdaterService()
    #endif

    @Published private(set) var canCheckForUpdates = false

    @Published private(set) var updateAvailabilityState = UpdateAvailabilityState.idle

    private let updaterController: SPUStandardUpdaterController?
    private let updaterDelegate = UpdaterDelegate()
    private let gentleReminderDelegate: GentleUpdateReminderDelegate

    init(startingUpdater: Bool = true, updatesEnabled: Bool = true) {
        gentleReminderDelegate = GentleUpdateReminderDelegate()
        guard updatesEnabled else {
            updaterController = nil
            return
        }

        updaterController = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: updaterDelegate,
            userDriverDelegate: gentleReminderDelegate
        )
        gentleReminderDelegate.onUpdateAvailable = { [weak self] version in
            self?.updateAvailable(version: version)
        }
        gentleReminderDelegate.onSessionFinished = { [weak self] in
            self?.updateSessionFinished()
        }
        bindCanCheckForUpdates()
        if startingUpdater { updaterController?.startUpdater() }
    }

    private func bindCanCheckForUpdates() {
        guard let updaterController else { return }
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    func updateAvailable(version: String) {
        updateAvailabilityState = .available(version: version)
    }

    func updateSessionFinished() {
        updateAvailabilityState = .idle
    }

    func installPendingUpdate() {
        updaterController?.checkForUpdates(nil)
    }

    var automaticallyChecksForUpdates: Bool {
        get { updaterController?.updater.automaticallyChecksForUpdates ?? false }
        set { updaterController?.updater.automaticallyChecksForUpdates = newValue }
    }
}
