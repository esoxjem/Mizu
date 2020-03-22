import Foundation

final class Preferences {
    
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func isSoundEnabled() -> Bool {
        return userDefaults.bool(forKey: PreferenceType.sound.rawValue)
    }
    
    func isStartupLaunch() -> Bool {
        return userDefaults.bool(forKey: PreferenceType.startup.rawValue)
    }
    
    func selectedInterval() -> Int {
        return userDefaults.integer(forKey: PreferenceType.interval.rawValue)
    }
    
    func saveSelectedInterval(_ interval: Int) {
        userDefaults.set(interval, forKey: PreferenceType.interval.rawValue)
    }
    
    func saveSound(isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: PreferenceType.sound.rawValue)
    }
    
    func saveStartupLaunch(isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: PreferenceType.startup.rawValue)
    }
}

enum PreferenceType: String {
    case interval
    case sound
    case startup
}
