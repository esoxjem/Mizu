import Combine
import XCTest

@MainActor
final class UpdaterServiceTests: XCTestCase {
    func testDisabledUpdaterCannotEnableProductionUpdates() {
        let key = "SUEnableAutomaticChecks"
        let originalValue = UserDefaults.standard.object(forKey: key)
        defer { UserDefaults.standard.set(originalValue, forKey: key) }
        let service = UpdaterService(startingUpdater: false, updatesEnabled: false)

        service.automaticallyChecksForUpdates = true

        XCTAssertFalse(service.automaticallyChecksForUpdates)
        XCTAssertFalse(service.canCheckForUpdates)
    }

    func testFinishingUpdateSessionPublishesIdleWithoutStaleVersion() {
        let service = UpdaterService(startingUpdater: false)
        var states: [UpdateAvailabilityState] = []
        let observation = service.$updateAvailabilityState.sink { states.append($0) }

        service.updateAvailable(version: "3.0")
        service.updateSessionFinished()

        XCTAssertEqual(states, [.idle, .available(version: "3.0"), .idle])
        XCTAssertFalse(service.updateAvailabilityState.isUpdateAvailable)
        XCTAssertNil(service.updateAvailabilityState.availableVersion)
        withExtendedLifetime(observation) {}
    }

    func testNewUpdateReplacesVersionInOnePublishedTransition() {
        let service = UpdaterService(startingUpdater: false)
        service.updateAvailable(version: "3.0")
        var states: [UpdateAvailabilityState] = []
        let observation = service.$updateAvailabilityState.dropFirst().sink { states.append($0) }

        service.updateAvailable(version: "3.1")

        XCTAssertEqual(states, [.available(version: "3.1")])
        withExtendedLifetime(observation) {}
    }

    func testSettingsAndUpdaterInitializationPreserveSparklesSavedOptOut() {
        let key = "SUEnableAutomaticChecks"
        let originalValue = UserDefaults.standard.object(forKey: key)
        let service = UpdaterService(startingUpdater: false)
        let originalChoice = service.automaticallyChecksForUpdates
        defer {
            service.automaticallyChecksForUpdates = originalChoice
            UserDefaults.standard.set(originalValue, forKey: key)
        }
        service.automaticallyChecksForUpdates = false
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(true, forKey: "automaticallyCheckForUpdates")

        _ = AppSettings(defaults: defaults)
        let restarted = UpdaterService(startingUpdater: false)

        XCTAssertFalse(restarted.automaticallyChecksForUpdates)
    }

    func testAvailableUpdateNotifiesPreferencesObserverWithOneStateChange() {
        let service = UpdaterService(startingUpdater: false)
        var changes = 0
        let observation = service.objectWillChange.sink { changes += 1 }

        service.updateAvailable(version: "3.0")

        XCTAssertEqual(changes, 1)
        XCTAssertTrue(service.updateAvailabilityState.isUpdateAvailable)
        XCTAssertEqual(service.updateAvailabilityState.availableVersion, "3.0")
        withExtendedLifetime(observation) {}
    }
}
