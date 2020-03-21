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
	
	private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
	private let popover = NSPopover()
	
	var eventMonitor: EventMonitor?
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		monitorOutsideClicks()
		initStatusBar()
		initPopover()
		startReminderTimer()
	}
	
	private func monitorOutsideClicks() {
		eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
			if let strongSelf = self {
				strongSelf.togglePopover()
			}
		}
	}
	
	private func initStatusBar() {
		if let button = statusItem.button {
			button.image = NSImage(named:NSImage.Name("StatusBarImage"))
		}
		
		statusItem.menu = createMenu()
	}
	
	private func createMenu() -> NSMenu {
		let menu = NSMenu()
		menu.addItem(NSMenuItem(title: "Preferences",
								action: #selector(togglePopover),
								keyEquivalent: ""))
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(title: "Quit",
								action: #selector(NSApplication.terminate(_:)),
								keyEquivalent: ""))
		return menu
	}
	
	@objc private func togglePopover() {
		if popover.isShown {
			closePopover()
		} else {
			showPopover()
		}
	}
	
	private func showPopover() {
		if let button = statusItem.button {
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
			eventMonitor?.start()
		}
	}
	
	private func closePopover() {
		popover.performClose(nil)
		eventMonitor?.stop()
	}
	
	private func initPopover() {
		popover.contentViewController = PreferencesViewController.newInstance()
	}
	
	private func startReminderTimer() {
		//todo schedule timer based on user preference
		
		Timer.scheduledTimer(timeInterval: 30,
							 target: self,
							 selector: #selector(showNotification),
							 userInfo: nil, repeats: true)
	}
	
	@objc private func showNotification() {
		//todo show mac notification
	}
	
}

