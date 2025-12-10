import SwiftUI

/// Modern @main entry point for the app using SwiftUI App lifecycle.
/// Uses NSApplicationDelegateAdaptor to bridge to AppDelegate for menu bar setup.
@main
struct MizuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty Settings scene - the app runs entirely from the menu bar
        Settings {
            EmptyView()
        }
    }
}
