import AppKit
import XCTest

@MainActor
final class ReminderServiceTests: XCTestCase {
    func testStartingTwiceKeepsOneReminderDeadline() async {
        let settings = makeSettings()
        let clock = ManualReminderClock()
        let delivered = expectation(description: "One reminder")
        let service = ReminderService(
            settings: settings,
            notificationCenter: NotificationCenter(),
            sleep: clock.sleep,
            notify: { _, _ in delivered.fulfill() }
        )
        defer { service.stop(); clock.resumeAll() }

        service.start()
        await clock.waitForSleep()
        service.start()
        clock.resumeNext()
        await fulfillment(of: [delivered], timeout: 1)
        await clock.waitForSleep(count: 2)

        XCTAssertEqual(clock.durations.count, 2)
    }

    func testStoppedReminderIgnoresWakeAndSettingsChanges() async {
        let settings = makeSettings()
        let clock = ManualReminderClock()
        let center = NotificationCenter()
        let delivered = expectation(description: "Stopped reminder stays stopped")
        delivered.isInverted = true
        let service = ReminderService(
            settings: settings,
            notificationCenter: center,
            sleep: clock.sleep,
            notify: { _, _ in delivered.fulfill() }
        )
        defer { service.stop(); clock.resumeAll() }

        service.start()
        await clock.waitForSleep()
        center.post(name: NSWorkspace.willSleepNotification, object: nil)
        service.stop()
        settings.selectedInterval = .thirtyMinutes
        center.post(name: NSWorkspace.didWakeNotification, object: nil)
        clock.resumeAll()

        await fulfillment(of: [delivered], timeout: 0.05)
        XCTAssertEqual(clock.durations.count, 1)
    }

    func testWakeStartsFreshIntervalUsingLatestSettings() async {
        let settings = makeSettings()
        let clock = ManualReminderClock()
        let center = NotificationCenter()
        let delivered = expectation(description: "Reminder after waking")
        var intervals: [ReminderInterval] = []
        let service = ReminderService(
            settings: settings,
            notificationCenter: center,
            sleep: clock.sleep,
            notify: { interval, _ in
                intervals.append(interval)
                delivered.fulfill()
            }
        )
        defer { service.stop(); clock.resumeAll() }

        service.start()
        await clock.waitForSleep()
        center.post(name: NSWorkspace.willSleepNotification, object: nil)
        settings.selectedInterval = .fortyFiveMinutes
        center.post(name: NSWorkspace.didWakeNotification, object: nil)
        await clock.waitForSleep(count: 2)
        clock.resumeAll()
        await fulfillment(of: [delivered], timeout: 1)

        XCTAssertEqual(clock.durations.prefix(2), [.seconds(3600), .seconds(2700)])
        XCTAssertEqual(intervals, [.fortyFiveMinutes])
    }

    func testSleepCancelsDeliveryDespiteSettingsChanges() async {
        let settings = makeSettings()
        let clock = ManualReminderClock()
        let center = NotificationCenter()
        let delivered = expectation(description: "No reminder while sleeping")
        delivered.isInverted = true
        let service = ReminderService(
            settings: settings,
            notificationCenter: center,
            sleep: clock.sleep,
            notify: { _, _ in delivered.fulfill() }
        )
        defer { service.stop(); clock.resumeAll() }

        service.start()
        await clock.waitForSleep()
        center.post(name: NSWorkspace.willSleepNotification, object: nil)
        settings.selectedInterval = .thirtyMinutes
        clock.resumeAll()

        await fulfillment(of: [delivered], timeout: 0.05)
        XCTAssertEqual(clock.durations.count, 1)
    }

    func testIntervalChangeReplacesPendingReminderWithoutViewCallback() async {
        let settings = makeSettings()
        let clock = ManualReminderClock()
        let delivered = expectation(description: "New interval delivered")
        var intervals: [ReminderInterval] = []
        let service = ReminderService(
            settings: settings,
            notificationCenter: NotificationCenter(),
            sleep: clock.sleep,
            notify: { interval, _ in
                intervals.append(interval)
                delivered.fulfill()
            }
        )
        defer { service.stop(); clock.resumeAll() }

        service.start()
        await clock.waitForSleep()
        settings.selectedInterval = .thirtyMinutes
        await clock.waitForSleep(count: 2)
        clock.resumeAll()
        await fulfillment(of: [delivered], timeout: 1)

        XCTAssertEqual(clock.durations.prefix(2), [.seconds(3600), .seconds(1800)])
        XCTAssertEqual(intervals, [.thirtyMinutes])
    }

    func testSoundChangeAppliesToNextReminderWithoutRestartingTimer() async {
        let settings = makeSettings()
        let clock = ManualReminderClock()
        let delivered = expectation(description: "Reminder delivered")
        var sounds: [Bool] = []
        let service = ReminderService(
            settings: settings,
            notificationCenter: NotificationCenter(),
            sleep: clock.sleep,
            notify: { _, sound in
                sounds.append(sound)
                delivered.fulfill()
            }
        )
        defer { service.stop(); clock.resumeAll() }

        service.start()
        await clock.waitForSleep()
        settings.isSoundEnabled = false
        clock.resumeNext()
        await fulfillment(of: [delivered], timeout: 1)

        XCTAssertEqual(sounds, [false])
        XCTAssertEqual(clock.durations.first, .seconds(ReminderInterval.oneHour.seconds))
    }

    private func makeSettings() -> AppSettings {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        addTeardownBlock { defaults.removePersistentDomain(forName: suiteName) }
        return AppSettings(defaults: defaults)
    }
}

@MainActor
final class ManualReminderClock {
    private var continuations: [CheckedContinuation<Void, Error>] = []
    private var onSleep: (() -> Void)?
    private(set) var durations: [Duration] = []

    func sleep(for duration: Duration) async throws {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
            durations.append(duration)
            onSleep?()
        }
    }

    func waitForSleep(count: Int = 1, file: StaticString = #filePath, line: UInt = #line) async {
        let sleeping = XCTestExpectation(description: "Timer is waiting")
        if durations.count >= count {
            sleeping.fulfill()
        } else {
            onSleep = { [weak self] in
                if let self, self.durations.count >= count { sleeping.fulfill() }
            }
        }
        let result = await XCTWaiter.fulfillment(of: [sleeping], timeout: 1)
        onSleep = nil
        XCTAssertEqual(result, .completed, file: file, line: line)
    }

    func resumeNext() {
        guard !continuations.isEmpty else { return }
        continuations.removeFirst().resume()
    }

    func resumeAll() {
        let pending = continuations
        continuations.removeAll()
        pending.forEach { $0.resume() }
    }
}
