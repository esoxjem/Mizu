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

	override func viewDidLoad() {
		super.viewDidLoad()
		updateSlider()
		updateSwitches()
	}
	
	private func updateSlider() {
		
	}

	private func updateSwitches() {
		
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


