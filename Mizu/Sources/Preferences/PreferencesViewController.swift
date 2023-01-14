import Cocoa
import SwiftUI

class PreferencesViewController: NSViewController {
    
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var playSoundSwitch: NSSwitch!
    @IBOutlet weak var launchStartupSwitch: NSSwitch!
    
    private let presenter = PreferencesPresenter()
    var intervalChanged: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad(view: self)
    }
    
    @IBAction func sliderUpdates(slider: NSSlider) {
        presenter.sliderMoved(value: Int(slider.intValue))
        intervalChanged?()
    }
    
    @IBAction func playSoundUpdates(_ sound: NSSwitch) {
        presenter.soundSwitchToggled(state: sound.state)
    }
    
    @IBAction func launchOnStartupUpdates(_ launch: NSSwitch) {
        presenter.startupSwitchToggled(state: launch.state)
    }
    
    @IBAction func settingsTap(_ sender: NSButton) {
        let menu = NSMenu()
        let twitter = NSMenuItem(title: "@ES0XJEM", action: #selector(twitter(_:)), keyEquivalent: "")
        let github = NSMenuItem(title: "GitHub", action: #selector(github(_:)), keyEquivalent: "")
        let quit = NSMenuItem(title: "Quit Mizu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        
        twitter.target = self
        github.target = self
        
        menu.addItem(twitter)
        menu.addItem(github)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quit)
        
        if let event = NSApplication.shared.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: sender)
        }
    }
    
    @objc private func twitter(_ sender: NSMenuItem) {
        let url = URL(string: "https://www.twitter.com/ES0XJEM")!
        NSWorkspace.shared.open(url)
    }
    
    @objc private func github(_ sender: NSMenuItem) {
        let url = URL(string: "https://www.github.com/esoxjem/Mizu")!
        NSWorkspace.shared.open(url)
    }
}

extension PreferencesViewController {
    
    static func newInstance() -> PreferencesViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("PreferencesViewController")
        guard let vc = storyboard.instantiateController(withIdentifier: identifier) as? PreferencesViewController else {
            fatalError("error loading storyboard")
        }
        
        return vc
    }
}

extension PreferencesViewController: PreferencesView {
    
    func setInterval(interval: Int) {
        slider.intValue = Int32(interval)
    }
    
    func enableSoundSwitch() {
        playSoundSwitch.state = .on
    }
    
    func disbleSoundSwitch() {
        playSoundSwitch.state = .off
    }
    
    func enableStartupSwitch() {
        launchStartupSwitch.state = .on
    }
    
    func disbleStartupSwitch() {
        launchStartupSwitch.state = .off
    }
    
    func close() {
        view.window?.close()
    }
}


