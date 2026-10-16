import Foundation
import XCTest

final class NotificationConfigurationTests: XCTestCase {
    func testNotificationsDefaultToPersistentAlerts() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let data = try Data(contentsOf: projectRoot.appendingPathComponent("Mizu/Info.plist"))
        let info = try XCTUnwrap(
            PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        )

        XCTAssertEqual(info["NSUserNotificationAlertStyle"] as? String, "alert")
    }
}
