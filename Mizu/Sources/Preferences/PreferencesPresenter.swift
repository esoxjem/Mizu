import Cocoa

final class PreferencesPresenter {
    
    private weak var view: PreferencesView?
    private let preferences: Preferences
    private var eventMonitor: EventMonitor?
    private var autoLaunch: AutoLaunch?
    
    
    init(preferences: Preferences = Preferences(), autoLaunch: AutoLaunch = AutoLaunch()) {
        self.preferences = preferences
        self.autoLaunch = autoLaunch
    }
    
    func viewDidLoad(view: PreferencesView) {
        self.view = view
        monitorOutsideClicks()
        restoreUserPreferences()
    }
    
    private func monitorOutsideClicks() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self {
                strongSelf.eventMonitor?.stop()
                strongSelf.view?.close()
            }
        }
        
        eventMonitor?.start()
    }
    
    private func restoreUserPreferences() {
        if preferences.isSoundEnabled() {
            view?.enableSoundSwitch()
        } else {
            view?.disbleSoundSwitch()
        }
        
        if preferences.isStartupLaunch() {
            view?.enableStartupSwitch()
        } else {
            view?.disbleStartupSwitch()
        }
        
        view?.setInterval(interval: preferences.selectedInterval())
    }
    
    func sliderMoved(value: Int) {
        preferences.saveSelectedInterval(value)
    }
    
    func soundSwitchToggled(state: NSSwitch.StateValue) {
        var isEnabled = true
        if state == .off {
            isEnabled = false
        }
        preferences.saveSound(isEnabled: isEnabled)
    }
    
    func startupSwitchToggled(state: NSSwitch.StateValue) {
        var isEnabled = true
        if state == .off {
            isEnabled = false
            autoLaunch?.disable()
        } else {
            autoLaunch?.enable()
        }
        
        preferences.saveStartupLaunch(isEnabled: isEnabled)
    }
}
