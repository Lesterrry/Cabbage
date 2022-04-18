//
//  ViewController.swift
//  Cabbage
//
//  Created by Lesterrry on 17.04.2022.
//

import Cocoa
import AppKit
import Quartz
import AVFoundation

class MainView: NSView {
	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		return true
	}
	override var acceptsFirstResponder : Bool {
		return true
	}
}

class MyQuickLookItem: NSObject, QLPreviewItem {
	var previewItemURL: URL!
}

class ViewController: NSViewController {
	
	//*********************************************************************
	// MARK: OUTLETS & ACTIONS
	//*********************************************************************
	@IBOutlet weak var chooseFilesButton: NSButton!
	@IBAction func chooseFilesButtonPressed(_ sender: Any) {
		onboardingMessageStackView.isHidden = true
		drawQuickLookPreview(with: "/Users/ajdarnasibullin/Downloads/w.mov")
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
	@IBOutlet weak var onboardingMessageStackView: NSStackView!
	@IBOutlet weak var unsupportedFileMessageStackView: NSStackView!
	@IBAction func unsupportedFileMessageViewRawButtonPressed(_ sender: Any) {
	}
	@IBOutlet weak var kittenImageView: NSImageView!
	
	//*********************************************************************
	// MARK: VARIABLES
	//*********************************************************************
	var videoPlayer: AVPlayer = AVPlayer()
	var kittenMode: Bool = false
	
	//*********************************************************************
	// MARK: MAIN FUNCTIONS
	//*********************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			self.myKeyDown(with: $0)
			return nil
		}
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
	
	func myKeyDown(with event: NSEvent) {
			super.keyDown(with: event)
			switch event.keyCode {
			case 12:  // Q
				exit(0)
			case 49:  // Space
				toggleKittenMode()
//			case 1:
//				stopEject()
//			case 36:
//				handleSet()
//			case 123:
//				move(false)
//			case 124:
//				move(true)
//			case 125:
//				changeFolder(false)
//			case 126:
//				changeFolder(true)
			default: ()
			}
		}
	
	func toggleKittenMode() {
		switch kittenMode {
		case false:
			kittenImageView.isHidden = false
			videoPlayer.pause()
			kittenMode = true
		case true:
			kittenImageView.isHidden = true
			videoPlayer.play()
			kittenMode = false
		}
	}
	
	func resetContentView() {
		for i in contentView.subviews {
			i.removeFromSuperview()
		}
		for i in contentView.layer!.sublayers! {
			i.removeFromSuperlayer()
		}
	}
	
	func drawQuickLookPreview(with path: String) {
		let quickLookView = QLPreviewView()
		let quickLookItem = MyQuickLookItem()
		quickLookItem.previewItemURL = URL(fileURLWithPath: path)
		quickLookView.previewItem = quickLookItem
		quickLookView.frame = NSRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
		quickLookView.autoresizingMask = [.height, .width]
		contentView.addSubview(quickLookView)
	}
	
	func drawVideoPlayer(with path: String) {
		let url = URL(fileURLWithPath: path)
		let asset = AVAsset(url: url)
		let playerItem = AVPlayerItem(asset: asset)
		videoPlayer = AVPlayer(playerItem: playerItem)
		let playerLayer = AVPlayerLayer(player: videoPlayer)
		playerLayer.frame = NSRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
		playerLayer.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
		playerLayer.videoGravity = .resizeAspect
		contentView.layer!.addSublayer(playerLayer)
		videoPlayer.play()
	}
	
	func drawImage(with data: Data) {
		let imageView = NSImageView()
		imageView.frame = NSRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
		imageView.autoresizingMask = [.height, .width]
		//let imageData = Data(contentsOf: <#T##URL#>)
		imageView.image = NSImage(data: data)
	}

}

