import Foundation
import Sparkle
import Combine

@MainActor
final class UpdaterService: ObservableObject {
    static let shared = UpdaterService()

    @Published private(set) var canCheckForUpdates = false

    private let updaterController: SPUStandardUpdaterController
    private var cancellable: AnyCancellable?

    private init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
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

    var automaticallyChecksForUpdates: Bool {
        get { updaterController.updater.automaticallyChecksForUpdates }
        set { updaterController.updater.automaticallyChecksForUpdates = newValue }
    }
}
