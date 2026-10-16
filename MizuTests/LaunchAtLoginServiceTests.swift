import ServiceManagement
import XCTest

@MainActor
final class LaunchAtLoginServiceTests: XCTestCase {
    func testFailedRegistrationKeepsToggleOff() {
        let service = LaunchAtLoginService(
            readStatus: { .notRegistered },
            register: { throw TestError.registrationFailed },
            unregister: {}
        )

        service.isEnabled = true

        XCTAssertFalse(service.isEnabled)
        XCTAssertEqual(service.status, .notRegistered)
    }

    func testFailedUnregistrationKeepsToggleOn() {
        let service = LaunchAtLoginService(
            readStatus: { .enabled },
            register: {},
            unregister: { throw TestError.registrationFailed }
        )

        service.isEnabled = false

        XCTAssertTrue(service.isEnabled)
        XCTAssertEqual(service.status, .enabled)
    }

    func testInitializationDoesNotChangeRegistration() {
        var changes = 0
        let service = LaunchAtLoginService(
            readStatus: { .enabled },
            register: { changes += 1 },
            unregister: { changes += 1 }
        )

        XCTAssertTrue(service.isEnabled)
        XCTAssertEqual(changes, 0)
    }

    func testToggleRechecksSystemStateBeforeDecidingRegistrationIsUnnecessary() {
        let loginItem = LoginItemStub()
        loginItem.status = .enabled
        var registerCalls = 0
        let service = LaunchAtLoginService(
            readStatus: { loginItem.status },
            register: {
                registerCalls += 1
                loginItem.status = .enabled
            },
            unregister: {}
        )
        loginItem.status = .notRegistered

        service.isEnabled = true

        XCTAssertEqual(registerCalls, 1)
        XCTAssertTrue(service.isEnabled)
    }

    func testDisablingRegistrationAwaitingApprovalUnregistersIt() {
        let loginItem = LoginItemStub()
        loginItem.status = .requiresApproval
        var unregisterCalls = 0
        let service = LaunchAtLoginService(
            readStatus: { loginItem.status },
            register: {},
            unregister: {
                unregisterCalls += 1
                loginItem.status = .notRegistered
            }
        )

        service.isEnabled = false

        XCTAssertEqual(unregisterCalls, 1)
        XCTAssertEqual(service.status, .notRegistered)
    }

    func testEnablingPublishesConfirmedSystemState() {
        let loginItem = LoginItemStub()
        let service = LaunchAtLoginService(
            readStatus: { loginItem.status },
            register: { loginItem.status = .enabled },
            unregister: { loginItem.status = .notRegistered }
        )

        service.isEnabled = true

        XCTAssertTrue(service.isEnabled)
        XCTAssertEqual(service.status, .enabled)
    }
}

private enum TestError: Error { case registrationFailed }

@MainActor
private final class LoginItemStub {
    var status = SMAppService.Status.notRegistered
}
