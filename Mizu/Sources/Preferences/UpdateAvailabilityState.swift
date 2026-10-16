enum UpdateAvailabilityState: Equatable {
    case idle
    case available(version: String)

    var isUpdateAvailable: Bool { availableVersion != nil }

    var availableVersion: String? {
        if case .available(let version) = self { return version }
        return nil
    }
}
