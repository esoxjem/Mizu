//
//  AppDelegate.swift
//  Mizu
//
//  Created by Arun Sasidharan on 17/12/19.
//  Copyright © 2019 Fuzzy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if let button = statusItem.button {
			button.image = NSImage(named:NSImage.Name("StatusBarImage"))
			button.action = #selector(statusBarIconClicked)
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	@objc func statusBarIconClicked() {
		debugPrint("icon clicked")
	}

}

