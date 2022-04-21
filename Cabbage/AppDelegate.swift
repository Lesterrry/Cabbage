//
//  AppDelegate.swift
//  Cabbage
//
//  Created by Lesterrry on 17.04.2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) { }

    func applicationWillTerminate(_ aNotification: Notification) {
		ViewController.clearTempFolder()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		true
	}

	@IBAction func visitGithubMenuItemPressed(_ sender: Any) {
		NSWorkspace.shared.open(URL(string: "https://github.com/Lesterrry/Cabbage")!)
	}

}
