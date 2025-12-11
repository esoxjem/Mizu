import Foundation
import Sparkle

@MainActor
final class UpdateAvailabilityState: ObservableObject {
    static let shared = UpdateAvailabilityState()

    @Published private(set) var isUpdateAvailable = false
    @Published private(set) var availableVersion: String?

    private init() {}

    func setUpdateAvailable(version: String) {
        isUpdateAvailable = true
        availableVersion = version
    }

    func clearPendingUpdate() {
        isUpdateAvailable = false
        availableVersion = nil
    }
}
