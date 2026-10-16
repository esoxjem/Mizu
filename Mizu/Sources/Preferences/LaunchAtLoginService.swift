import Foundation
import Combine
import ServiceManagement
import OSLog

@MainActor
final class LaunchAtLoginService: ObservableObject {
    static let shared = LaunchAtLoginService()

    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "LaunchAtLogin")
    private let readStatus: () -> SMAppService.Status
    private let register: () throws -> Void
    private let unregister: () throws -> Void
    @Published private(set) var status: SMAppService.Status

    init(
        readStatus: @escaping () -> SMAppService.Status = { SMAppService.mainApp.status },
        register: @escaping () throws -> Void = { try SMAppService.mainApp.register() },
        unregister: @escaping () throws -> Void = { try SMAppService.mainApp.unregister() }
    ) {
        self.readStatus = readStatus
        self.register = register
        self.unregister = unregister
        status = readStatus()
    }

    /// Whether launch at login is currently enabled
    var isEnabled: Bool {
        get { status == .enabled }
        set {
            refresh()
            defer { refresh() }
            do {
                switch (status, newValue) {
                case (.enabled, true), (.notRegistered, false), (.notFound, false):
                    break
                case (_, true):
                    try register()
                case (_, false):
                    try unregister()
                }
            } catch {
                logger.error("Failed to change launch at login: \(error.localizedDescription)")
            }
        }
    }

    func refresh() {
        status = readStatus()
    }
}
