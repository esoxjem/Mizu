//
//  ViewController.swift
//  Mizu
//
//  Created by Arun Sasidharan on 17/12/19.
//  Copyright © 2020 voidmain.dev. All rights reserved.
//

import Cocoa
import SwiftUI

class PreferencesViewController: NSViewController {
	
	@IBOutlet weak var slider: NSSlider!
	@IBOutlet weak var playSoundSwitch: NSSwitch!
	@IBOutlet weak var launchStartupSwitch: NSSwitch!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateSlider()
		updateSwitches()
	}
	
	private func updateSlider() {
		slider.intValue = Int32(UserDefaults.standard.integer(forKey: Preferences.interval.rawValue))
	}
	
	private func updateSwitches() {
		if UserDefaults.standard.bool(forKey: Preferences.sound.rawValue) {
			playSoundSwitch.state = .on
		} else {
			playSoundSwitch.state = .off
		}
		
		if UserDefaults.standard.bool(forKey: Preferences.startup.rawValue) {
			launchStartupSwitch.state = .on
		} else {
			launchStartupSwitch.state = .off
		}
	}
	
	@IBAction func sliderUpdates(slider: NSSlider) {
		debugPrint("slider: \(slider.intValue)")
		UserDefaults.standard.set(slider.intValue, forKey: Preferences.interval.rawValue)
		(NSApp.delegate as? AppDelegate)?.resetTimer()
	}
	
	@IBAction func playSoundUpdates(_ sound: NSSwitch) {
		var isEnabled = true
		if sound.state == .off {
			isEnabled = false
		}
		UserDefaults.standard.set(isEnabled, forKey: Preferences.sound.rawValue)
	}
	
	@IBAction func launchOnStartupUpdates(_ launch: NSSwitch) {
		var isEnabled = true
		if launch.state == .off {
			isEnabled = false
		}
		UserDefaults.standard.set(isEnabled, forKey: Preferences.startup.rawValue)
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


