import Foundation
import LaunchAtLogin

class AutoLaunch {
    func enable() {
        LaunchAtLogin.isEnabled = true
    }
    
    func disable() {
        LaunchAtLogin.isEnabled = false
    }
}
