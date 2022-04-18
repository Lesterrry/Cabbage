//
//  ViewController.swift
//  Cabbage
//
//  Created by Lesterrry on 17.04.2022.
//

import Cocoa
import AppKit
import Quartz

class MyQuickLookItem: NSObject, QLPreviewItem {
	var previewItemURL: URL!
}

class ViewController: NSViewController {
	
	//*********************************************************************
	// MARK: OUTLETS & ACTIONS
	//*********************************************************************
	@IBOutlet weak var chooseFilesButton: NSButton!
	@IBAction func chooseFilesButtonPressed(_ sender: Any) {
	}
	@IBOutlet weak var fileSequenceBackButton: NSButton!
	@IBAction func fileSequenceBackButtonPressed(_ sender: Any) {
	}
	@IBOutlet weak var fileSequenceIndexLabel: NSTextField!
	@IBOutlet weak var fileSequenceForwardButton: NSButton!
	@IBAction func fileSequenceForwardButtonPressed(_ sender: Any) {
	}
	@IBOutlet weak var fileInfoStackView: NSStackView!
	@IBOutlet weak var fileInfoNameLabel: NSTextField!
	@IBOutlet weak var fileInfoStatusLabel: NSTextField!
	@IBOutlet weak var contentView: NSView!
	
	//*********************************************************************
	// MARK: MAIN FUNCTIONS
	//*********************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
		let quickLookView = QLPreviewView()
		let quickLookItem = MyQuickLookItem()
		quickLookItem.previewItemURL = URL(fileURLWithPath: "/Users/ajdarnasibullin/Downloads/DJI_0072.mp4")
		quickLookView.previewItem = quickLookItem
		quickLookView.frame = NSRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
		quickLookView.autoresizingMask = [.height, .width]
		contentView.addSubview(quickLookView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

