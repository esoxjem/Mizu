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


