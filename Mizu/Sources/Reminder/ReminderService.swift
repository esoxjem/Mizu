import AppKit
import Combine

@MainActor
final class ReminderService {
    private enum State { case stopped, running, sleeping }
    private var state = State.stopped
    private var reminderTask: Task<Void, Never>?
    private var intervalObservation: AnyCancellable?
    private let notificationCenter: NotificationCenter
    private var sleepObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?
    private let settings: AppSettings
    private let sleep: (Duration) async throws -> Void
    private let notify: (ReminderInterval, Bool) async -> Void

    init(
        settings: AppSettings,
        notificationCenter: NotificationCenter = NSWorkspace.shared.notificationCenter,
        sleep: @escaping (Duration) async throws -> Void = {
            try await Task.sleep(for: $0, clock: .suspending)
        },
        notify: @escaping (ReminderInterval, Bool) async -> Void = { interval, sound in
            await NotificationActor.shared.deliverNotification(
                title: "Time to drink water",
                body: "It's been \(interval.displayString) since your last glass.",
                withSound: sound
            )
        }
    ) {
        self.settings = settings
        self.notificationCenter = notificationCenter
        self.sleep = sleep
        self.notify = notify
        intervalObservation = settings.$selectedInterval
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] interval in
                guard let self, self.state == .running else { return }
                self.schedule(interval: interval)
            }
        sleepObserver = notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.systemWillSleep() }
        }
        wakeObserver = notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.systemDidWake() }
        }
    }

    func start() {
        guard state == .stopped else { return }
        state = .running
        schedule(interval: settings.selectedInterval)
    }

    func stop() {
        state = .stopped
        cancelTimer()
    }

    private func systemWillSleep() {
        guard state == .running else { return }
        state = .sleeping
        cancelTimer()
    }

    private func systemDidWake() {
        guard state == .sleeping else { return }
        state = .running
        schedule(interval: settings.selectedInterval)
    }

    private func cancelTimer() {
        reminderTask?.cancel()
        reminderTask = nil
    }

    private func schedule(interval: ReminderInterval) {
        reminderTask?.cancel()
        reminderTask = Task { [settings, sleep, notify] in
            while !Task.isCancelled {
                do {
                    try await sleep(.seconds(interval.seconds))
                    guard !Task.isCancelled else { return }
                    await notify(interval, settings.isSoundEnabled)
                } catch {
                    return
                }
            }
        }
    }

    deinit {
        reminderTask?.cancel()
        if let sleepObserver { notificationCenter.removeObserver(sleepObserver) }
        if let wakeObserver { notificationCenter.removeObserver(wakeObserver) }
    }
}
