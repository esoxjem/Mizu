//
//  ViewController.swift
//  Mizu
//
//  Created by Arun Sasidharan on 17/12/19.
//  Copyright © 2019 Fuzzy. All rights reserved.
//

import Cocoa
import SwiftUI

class PreferencesViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
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


