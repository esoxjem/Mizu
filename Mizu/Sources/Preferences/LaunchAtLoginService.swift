import Foundation
import ServiceManagement
import OSLog

/// Service managing launch-at-login functionality using native SMAppService.
///
/// Uses the modern SMAppService API (macOS 13+) to register the app as a login item.
/// This replaces the need for external dependencies like LaunchAtLogin.
@MainActor
final class LaunchAtLoginService {
    static let shared = LaunchAtLoginService()

    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "LaunchAtLogin")
    private let service = SMAppService.mainApp

    private init() {}

    /// Whether launch at login is currently enabled
    var isEnabled: Bool {
        service.status == .enabled
    }

    /// Enable launch at login
    func enable() {
        guard service.status != .enabled else {
            logger.info("Launch at login already enabled")
            return
        }

        do {
            try service.register()
            logger.info("Successfully registered launch at login")
        } catch {
            logger.error("Failed to register launch at login: \(error.localizedDescription)")
        }
    }

    /// Disable launch at login
    func disable() {
        guard service.status == .enabled else {
            logger.info("Launch at login already disabled")
            return
        }

        do {
            try service.unregister()
            logger.info("Successfully unregistered launch at login")
        } catch {
            logger.error("Failed to unregister launch at login: \(error.localizedDescription)")
        }
    }
}
