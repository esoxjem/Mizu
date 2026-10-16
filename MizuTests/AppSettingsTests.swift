import XCTest

@MainActor
final class AppSettingsTests: XCTestCase {
    func testEditedReminderPreferencesSurviveNewSettingsInstance() {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let settings = AppSettings(defaults: defaults)

        settings.selectedInterval = .ninetyMinutes
        settings.isSoundEnabled = false
        let restored = AppSettings(defaults: defaults)

        XCTAssertEqual(restored.selectedInterval, .ninetyMinutes)
        XCTAssertFalse(restored.isSoundEnabled)
    }

    func testInvalidStoredIntervalUsesDefault() {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(99, forKey: "interval")

        XCTAssertEqual(AppSettings(defaults: defaults).selectedInterval, .oneHour)
    }
}
