import Foundation
import Combine

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults: UserDefaults

    @Published var selectedInterval: ReminderInterval {
        didSet { defaults.set(selectedInterval.rawValue, forKey: "interval") }
    }
    @Published var isSoundEnabled: Bool {
        didSet { defaults.set(isSoundEnabled, forKey: "sound") }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let rawInterval = defaults.object(forKey: "interval") as? Int ?? ReminderInterval.oneHour.rawValue
        selectedInterval = ReminderInterval(rawValue: rawInterval) ?? .oneHour
        isSoundEnabled = defaults.object(forKey: "sound") as? Bool ?? true
    }
}
