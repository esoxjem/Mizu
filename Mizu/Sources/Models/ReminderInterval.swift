import Foundation

/// Strongly-typed enum representing the available reminder intervals.
/// Replaces magic numbers (0-4) with type-safe cases.
enum ReminderInterval: Int, CaseIterable, Identifiable {
    case thirtyMinutes = 0
    case fortyFiveMinutes = 1
    case oneHour = 2
    case ninetyMinutes = 3
    case twoHours = 4

    var id: Int { rawValue }

    /// The interval duration in seconds
    var seconds: TimeInterval {
        switch self {
        case .thirtyMinutes: return 30 * 60
        case .fortyFiveMinutes: return 45 * 60
        case .oneHour: return 60 * 60
        case .ninetyMinutes: return 90 * 60
        case .twoHours: return 120 * 60
        }
    }

    /// Human-readable display string for the interval
    var displayString: String {
        switch self {
        case .thirtyMinutes: return "30 mins"
        case .fortyFiveMinutes: return "45 mins"
        case .oneHour: return "1 hour"
        case .ninetyMinutes: return "1.5 hours"
        case .twoHours: return "2 hours"
        }
    }
}
