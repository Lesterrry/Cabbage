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
	@IBOutlet weak var fileInfoCookButton: NSButton!
	@IBAction func fileInfoCookButtonPressed(_ sender: Any) {
		tryCook()
	}
	@IBOutlet weak var contentView: NSView!
	@IBOutlet weak var onboardingMessageStackView: NSStackView!
	@IBOutlet weak var folderMessageStackView: NSStackView!
	@IBAction func folderMessageDiveButtonPressed(_ sender: Any) {
	}
	@IBOutlet weak var cookingMessageStackView: NSStackView!
	@IBOutlet weak var cookingMessageProgressIndicator: NSProgressIndicator!
	@IBOutlet weak var kittenImageView: NSImageView!
	
	//*********************************************************************
	// MARK: VARIABLES, CONSTS & ENUMS
	//*********************************************************************
	var videoPlayer: AVPlayer = AVPlayer()
	var kittenMode: Bool = false
	var files: [URL] = []
	var currentIndex: Int = 0
	var currentFileType = FileType.unknown
	var batchCookEnabled = false
	let fileManager = FileManager.default
	
	enum FileType {
		case raw
		case undercooked
		case deepfried
		case unknown
	}
	
	//*********************************************************************
	// MARK: MAIN FUNCTIONS
	//*********************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			self.myKeyDown(with: $0)
			return nil
		}
		NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
			self.myFlagsChanged(with: $0)
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
		default:
			#if DEBUG
			print("key down: \(event.keyCode)")
			#else
			()
			#endif
		}
	}
	
	func myFlagsChanged(with event: NSEvent) {
		super.flagsChanged(with: event)
		guard currentFileType != .unknown else {
			return
		}
		if event.keyCode == 58 {  // Option
			switch event.modifierFlags.rawValue {
			case 0x100, 0:  // None (release)
				batchCookEnabled = false
				if currentFileType == .raw {
					fileInfoCookButton.title = Strings.COOK
				} else {
					fileInfoCookButton.title = Strings.UNCOOK
				}
			default:  // Pressed
				batchCookEnabled = true
				fileInfoCookButton.title = Strings.BATCH_COOK
			}
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
		cookingMessageStackView.isHidden = true
		#warning("Dumbass approach")
		for i in contentView.subviews[3..<contentView.subviews.count] {
			i.removeFromSuperview()
		}
		if let sublayers = contentView.layer!.sublayers {
			for i in sublayers[3..<sublayers.count] {
				i.removeFromSuperlayer()
			}
		}
	}
	
	func showCookingMessage() {
		resetContentView()
		cookingMessageStackView.isHidden = false
		cookingMessageProgressIndicator.startAnimation(nil)
	}
	
	func tryCook() {
		guard files.count > 0 else {
			return
		}
		showCookingMessage()
		if batchCookEnabled {
			for i in files {
				do {
					files[currentIndex] = try Kitchen.cook(i, with: fileManager)
				} catch let err {
					#if DEBUG
					print(err.localizedDescription)
					#endif
				}
			}
		} else {
			if currentFileType == .raw {
				do {
					files[currentIndex] = try Kitchen.cook(files[currentIndex], with: fileManager)
				} catch let err {
					displayAlert(title: Strings.RECOVERABLE_COOKINGCATASTROPHE, message: err.localizedDescription, buttons: Strings.FINE)
				}
			} else {
				do {
					files[currentIndex] = try Kitchen.uncook(files[currentIndex], with: fileManager)
				} catch let err {
					displayAlert(title: Strings.RECOVERABLE_COOKINGCATASTROPHE, message: err.localizedDescription, buttons: Strings.FINE)
				}
			}
		}
		drawFile(files[currentIndex])
	}
	
	@discardableResult
		func displayAlert(title: String, message: String, buttons: String...) -> Int {
			let alert = NSAlert()
			alert.messageText = title
			alert.informativeText = message
			for button in buttons{
				alert.addButton(withTitle: button)
			}
			return alert.runModal().rawValue
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
			drawFile(files[currentIndex])
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
				case Strings.UNDERCOOKED_FILE_EXTENSION:  // Undercooked file
					currentFileType = .undercooked
					fileInfoStatusLabel.stringValue = Strings.UNDERCOOKED
					fileInfoStatusLabel.textColor = NSColor.systemYellow
					fileInfoCookButton.title = Strings.UNCOOK
					let decooked = file.deletingPathExtension()
					drawQuickLookPreview(with: decooked.path)
				case Strings.DEEPFRIED_FILE_EXTENSION:    // Deep-fried file
					currentFileType = .deepfried
					fileInfoStatusLabel.stringValue = Strings.DEEPFRIED
					fileInfoStatusLabel.textColor = NSColor.systemGreen
					fileInfoCookButton.title = Strings.UNCOOK
					do {
					try drawImage(with: Kitchen.cookedData(from: file, with: fileManager))
					} catch let err {
						displayAlert(title: Strings.RECOVERABLE_COOKINGDATACATASTROPHE, message: err.localizedDescription, buttons: Strings.FINE)
					}
				default:                                  // Raw file
					currentFileType = .raw
					fileInfoStatusLabel.stringValue = Strings.RAW
					fileInfoStatusLabel.textColor = NSColor.secondaryLabelColor
					fileInfoCookButton.title = Strings.COOK
					drawQuickLookPreview(with: file.path)
				}
			}
		} else {
			fatalError(Strings.FATAL_NOFILE)
		}
	}

}

