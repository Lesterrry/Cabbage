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
		askForFiles()
	}
	@IBOutlet weak var fileSequenceStackView: NSStackView!
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
	@IBOutlet weak var folderMessageStackView: NSStackView!
	@IBAction func folderMessageDiveButtonPressed(_ sender: Any) {
	}
	@IBOutlet weak var kittenImageView: NSImageView!
	
	//*********************************************************************
	// MARK: VARIABLES & CONSTS
	//*********************************************************************
	var videoPlayer: AVPlayer = AVPlayer()
	var kittenMode: Bool = false
	var files: [URL] = []
	var currentIndex: Int64 = 0
	let fileManager = FileManager.default
	
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
		folderMessageStackView.isHidden = true
		// FIXME:
		// Dumbass approach
		for i in contentView.subviews[2..<contentView.subviews.count] {
			i.removeFromSuperview()
		}
		if let sublayers = contentView.layer!.sublayers {
			for i in sublayers[2..<sublayers.count] {
				i.removeFromSuperlayer()
			}
		}
	}
	
	func drawQuickLookPreview(with path: String) {
		let quickLookView = QLPreviewView()
		let quickLookItem = MyQuickLookItem()
		quickLookItem.previewItemURL = URL(fileURLWithPath: path)
		quickLookView.previewItem = quickLookItem
		placeView(quickLookView)
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
		//let imageData = Data(contentsOf: <#T##URL#>)
		imageView.image = NSImage(data: data)
		placeView(imageView)
	}
	
	func drawFolder() {
		folderMessageStackView.isHidden = false
	}
	
	func placeView(_ view: NSView) {
		view.frame = NSRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
		view.autoresizingMask = [.height, .width]
		contentView.addSubview(view)
	}
	
	func askForFiles() {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = true
		panel.canChooseDirectories = true
		if panel.runModal() == .OK {
			guard panel.urls.count > 0 else {
				return
			}
			onboardingMessageStackView.isHidden = true
			fileSequenceStackView.isHidden = false
			fileInfoStackView.isHidden = false
			files = panel.urls
			drawFile(files[Int(currentIndex)])
		}
	}
	
	func drawFile(_ file: URL) {
		resetContentView()
		var isDir : ObjCBool = false
		if fileManager.fileExists(atPath: file.path, isDirectory:&isDir) {
			fileInfoNameLabel.stringValue = file.lastPathComponent
			if isDir.boolValue {
				drawFolder()
			} else {
				switch file.pathExtension {
				case Strings.UNDERCOOKED_FILE_EXTENSION:
					fileInfoStatusLabel.stringValue = Strings.UNDERCOOKED
					fileInfoStatusLabel.textColor = NSColor.systemYellow
				case Strings.DEEPFRIED_FILE_EXTENSION:
					fileInfoStatusLabel.stringValue = Strings.DEEPFRIED
					fileInfoStatusLabel.textColor = NSColor.systemGreen
				default:
					fileInfoStatusLabel.stringValue = Strings.RAW
					fileInfoStatusLabel.textColor = NSColor.secondaryLabelColor
				}
				let decooked = file.deletingPathExtension()
				print(decooked.pathExtension)
			}
		} else {
			fatalError(Strings.FATAL_NOFILE)
		}
	}

}

