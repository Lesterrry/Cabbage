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

	override var acceptsFirstResponder: Bool {
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
	@IBOutlet weak var fileSequenceBackButton: NSButton!
	@IBAction func fileSequenceBackButtonPressed(_ sender: Any) {
		if alternateClickAction {
			moveSequence(.home)
		} else {
			moveSequence(.backward)
		}
	}
	@IBOutlet weak var fileSequenceIndexLabel: NSTextField!
	@IBOutlet weak var fileSequenceForwardButton: NSButton!
	@IBAction func fileSequenceForwardButtonPressed(_ sender: Any) {
		if alternateClickAction {
			moveSequence(.random)
		} else {
			moveSequence(.forward)
		}
	}
	@IBOutlet weak var fileSequenceUndiveButton: NSButton!
	@IBAction func fileSequenceUndiveButtonPressed(_ sender: Any) {
		try? undive()
	}
	@IBOutlet weak var fileInfoNameLabel: NSTextField!
	@IBOutlet weak var fileInfoStatusLabel: NSTextField!
	@IBOutlet weak var fileInfoCookButton: NSButton!
	@IBAction func fileInfoCookButtonPressed(_ sender: Any) {
		tryCook()
	}
	@IBOutlet weak var contentView: NSView!
	@IBOutlet weak var controlsView: NSView!
	@IBOutlet weak var onboardingMessageStackView: NSStackView!
	@IBOutlet weak var folderMessageStackView: NSStackView!
	@IBAction func folderMessageDiveButtonPressed(_ sender: Any) {
		try? dive()
	}
	@IBOutlet weak var cookingMessageStackView: NSStackView!
	@IBOutlet weak var cookingMessageProgressIndicator: NSProgressIndicator!
	@IBOutlet weak var catastopheMessageStackView: NSStackView!
	@IBOutlet weak var catastropheMessageDescriptionLabel: NSTextField!
	@IBOutlet weak var dangerousMessageStackView: NSStackView!
	@IBAction func dangerousMessageProceedButtonPressed(_ sender: Any) {
		drawFile(files[currentIndex], force: true)
	}
	@IBOutlet weak var kittenImageView: NSImageView!
	
	//*********************************************************************
	// MARK: VARIABLES, CONSTS & ENUMS
	//*********************************************************************
	var kittenMode: Bool = false
	var files: [URL] = []
	var currentIndex: Int = 0
	var currentFileType = FileType.unknown
	var currentFileSequenceType = SequenceType.unknown
	var alternateClickAction = false
	lazy var videoPlayer: AVPlayer = AVPlayer()
	lazy var divingHistory: [URL] = []
	lazy var predivingFiles: [URL]? = nil
	let fileManager = FileManager.default
	let tempFolder = NSTemporaryDirectory()
	
	enum FileType {
		case raw
		case deepfried
		case unknown
	}
	enum SequenceType {
		case cooked
		case unknown
	}
	enum SequenceMoveType {
		case forward
		case backward
		case home
		case random
	}
	
	//*********************************************************************
	// MARK: SYSTEM SECTION
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
	
	//*********************************************************************
	// MARK: KEYS SECTION
	//*********************************************************************
	func myKeyDown(with event: NSEvent) {
		super.keyDown(with: event)
		switch event.keyCode {
		case 12:  // Q
			NSApp.terminate(self)
		case 49:  // Space
			toggleKittenMode()
		case 124:  // Right
			moveSequence(.forward)
		case 123:  // Left
			moveSequence(.backward)
		case 36:  // Return
			tryCook()
		case 8:  // `C`
			askForFiles()
		default:
			#if DEBUG
			print("key down: \(event.keyCode)")
			#else
			break
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
				alternateClickAction = false
				fileSequenceBackButton.image = NSImage(named: "NSGoBackTemplate")
				fileSequenceForwardButton.image = NSImage(named: "NSGoForwardTemplate")
				if currentFileType == .raw {
					fileInfoCookButton.title = Strings.COOK
				} else {
					fileInfoCookButton.title = Strings.UNCOOK
				}
			default:  // Pressed
				alternateClickAction = true
				fileSequenceBackButton.image = NSImage(named: "NSHomeTemplate")
				fileSequenceForwardButton.image = NSImage(named: "NSRefreshTemplate")
				if currentFileSequenceType == .unknown {
					fileInfoCookButton.title = Strings.BATCH_COOK
				} else {
					fileInfoCookButton.title = Strings.BATCH_UNCOOK
				}
			}
		}
	}

	//*********************************************************************
	// MARK: GENERAL DATA SECTION
	//*********************************************************************
	func resetContentView() {
		for i in contentView.subviews[0..<5] {
			i.isHidden = true
		}
		for i in contentView.subviews[5..<contentView.subviews.count] {
			i.removeFromSuperview()
		}
		if let sublayers = contentView.layer!.sublayers {
			for i in sublayers[5..<sublayers.count] {
				i.removeFromSuperlayer()
			}
		}
	}
	func setControlViewEnabled(_ to: Bool) {
		chooseFilesButton.isEnabled = to
		fileSequenceBackButton.isEnabled = to
		fileSequenceForwardButton.isEnabled = to
	}
	static func clearTempFolder() {
		let tempFolder = NSTemporaryDirectory()
		let fileManager = FileManager.default
		guard let toClear = try? fileManager.contentsOfDirectory(atPath: tempFolder) else {
			return
		}
		for i in toClear {
			let file = tempFolder.appending("/\(i)")
			var isDir: ObjCBool = false
			if fileManager.fileExists(atPath: file, isDirectory: &isDir) {
				if isDir.boolValue {
					continue
				}
				try? fileManager.removeItem(atPath: file)
			} else {
				fatalError(Strings.FATAL_NOTEMPDIR)
			}
		}
	}
	func setFileSequenceIndexLabel() {
		fileSequenceIndexLabel.stringValue = "\(currentIndex + 1)/\(files.count)"
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
	func moveSequence(_ to: SequenceMoveType) {
		switch to {
		case .backward:
			if currentIndex > 0 {
				currentIndex -= 1
			} else {
				currentIndex = files.count - 1
			}
		case .forward:
			if currentIndex < files.count - 1 {
				currentIndex += 1
			} else {
				currentIndex = 0
			}
		case .home:
			currentIndex = 0
		case .random:
			currentIndex = Int.random(in: 0 ..< files.count)
		}
		setFileSequenceIndexLabel()
		drawFile(files[currentIndex])
	}
	func analyzeFileSequence() {
		for i in files where i.pathExtension != Strings.DEEPFRIED_FILE_EXTENSION {
			currentFileSequenceType = .unknown
			return
		}
		currentFileSequenceType = .cooked
	}
	func dive() throws {
		let folder = files[currentIndex]
		var isDir: ObjCBool = false
		guard fileManager.fileExists(atPath: folder.path, isDirectory: &isDir), isDir.boolValue else {
			fatalError(Strings.FATAL_NOTFOLDER)
		}
		if predivingFiles == nil {
			predivingFiles = files
		}
		divingHistory.append(folder)
		currentIndex = 0
		try fillFiles(with: folder)
		fileSequenceUndiveButton.isHidden = false
		setFileSequenceIndexLabel()
		drawFile(files[0])
	}
	func undive() throws {
		guard let pref = predivingFiles else {
			return
		}
		if divingHistory.count == 1 {
			divingHistory = []
			predivingFiles = nil
			files = pref
			fileSequenceUndiveButton.isHidden = true
		} else {
			try fillFiles(with: divingHistory[divingHistory.count - 2])
			divingHistory.removeLast(1)
		}
		setFileSequenceIndexLabel()
		drawFile(files[0])
	}
	func fillFiles(with folder: URL) throws {
		let newFiles = try fileManager.contentsOfDirectory(atPath: folder.path)
		guard newFiles.count > 0 else {
			return
		}
		files = []
		for f in newFiles {
			files.append(folder.appendingPathComponent(f))
		}
	}

	//*********************************************************************
	// MARK: UI SECTION
	//*********************************************************************
	@discardableResult
	func displayAlert(title: String, message: String, buttons: String...) -> Int {
		let alert = NSAlert()
		alert.messageText = title
		alert.informativeText = message
		for button in buttons {
			alert.addButton(withTitle: button)
		}
		return alert.runModal().rawValue
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
			controlsView.isHidden = false
			files = panel.urls
			analyzeFileSequence()
			setFileSequenceIndexLabel()
			drawFile(files[currentIndex])
		}
	}
	func drawQuickLookPreview(with path: String) {
		let quickLookView = QLPreviewView()
		let quickLookItem = MyQuickLookItem()
		quickLookItem.previewItemURL = URL(fileURLWithPath: path)
		quickLookView.previewItem = quickLookItem
		placeView(quickLookView)
	}
	func drawImage(with data: Data) {
		let imageView = NSImageView()
		imageView.image = NSImage(data: data)
		placeView(imageView)
	}
	func drawFolder() {
		folderMessageStackView.isHidden = false
	}
	func drawCatastrophe(_ message: String) {
		catastropheMessageDescriptionLabel.stringValue = message
		catastopheMessageStackView.isHidden = false
		controlsView.isHidden = true
	}
	func drawCooking() {
		resetContentView()
		cookingMessageStackView.isHidden = false
		cookingMessageProgressIndicator.startAnimation(nil)
	}
	func drawDangerous() {
		dangerousMessageStackView.isHidden = false
	}
	func drawOnboarding() {
		onboardingMessageStackView.isHidden = false
	}
	func placeView(_ view: NSView) {
		view.frame = NSRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
		view.autoresizingMask = [.height, .width]
		contentView.addSubview(view)
	}

	//*********************************************************************
	// MARK: LOGIC SESSION
	//*********************************************************************
	func tryCook() {
		guard files.count > 0 else {
			return
		}
		drawCooking()
		setControlViewEnabled(false)
		DispatchQueue.main.async {
			if self.alternateClickAction {
				for i in 0 ..< self.files.count {
					do {
						self.files[i] = try Kitchen.workCulinaryMiracle(with: self.files[i], using: self.fileManager)
					} catch {
						#if DEBUG
						fatalError()
						#endif
					}
				}
			} else {
				do {
					self.files[self.currentIndex] = try Kitchen.workCulinaryMiracle(
						with: self.files[self.currentIndex],
						using: self.fileManager
					)
				} catch let err {
					self.displayAlert(
						title: Strings.RECOVERABLE_COOKINGCATASTROPHE,
						message: err.localizedDescription,
						buttons: Strings.FINE
					)
				}
			}
			self.drawFile(self.files[self.currentIndex])
			self.analyzeFileSequence()
			self.setControlViewEnabled(true)
		}
	}
	func drawFile(_ file: URL, force: Bool = false) {
		resetContentView()
		ViewController.clearTempFolder()
		var isDir: ObjCBool = false
		if fileManager.fileExists(atPath: file.path, isDirectory: &isDir) {
			fileInfoNameLabel.stringValue = file.lastPathComponent
			if isDir.boolValue {
				fileInfoCookButton.isEnabled = false
				currentFileType = .unknown
				fileInfoStatusLabel.stringValue = Strings.FOLDER
				fileInfoStatusLabel.textColor = NSColor.secondaryLabelColor
				fileInfoCookButton.title = Strings.COOK
				drawFolder()
			} else {
				fileInfoCookButton.isEnabled = true
				switch file.pathExtension {
				case Strings.DEEPFRIED_FILE_EXTENSION:    // Deep-fried file
					currentFileType = .deepfried
					fileInfoStatusLabel.stringValue = Strings.DEEPFRIED
					fileInfoStatusLabel.textColor = NSColor.systemGreen
					fileInfoCookButton.title = Strings.UNCOOK
					let realFile = file.deletingPathExtension()
					if Kitchen.KNOWN_IMAGE_FILE_EXTENSIONS.contains(realFile.pathExtension.lowercased()) {
						do {
							try drawImage(with: Kitchen.cookedData(from: file, with: fileManager))
						} catch let err {
							drawCatastrophe(err.localizedDescription)
						}
					} else {
						do {
							let attr = try fileManager.attributesOfItem(atPath: file.path)
							if let size = attr[FileAttributeKey.size] as? UInt64,
							   size > 20971520,
							   !force {
								drawDangerous()
								return
							}
							drawCooking()
							setControlViewEnabled(false)
							DispatchQueue.main.async {
								do {
									let data = try Kitchen.cookedData(from: file, with: self.fileManager)
									let tempFile = self.tempFolder.appending(realFile.lastPathComponent)
									try data.write(to: URL(fileURLWithPath: tempFile))
									self.drawQuickLookPreview(with: tempFile)
									self.setControlViewEnabled(true)
								} catch let err {
									self.drawCatastrophe(err.localizedDescription)
								}
							}
						} catch let err {
							drawCatastrophe(err.localizedDescription)
						}
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
			resetContentView()
			files = []
			currentIndex = 0
			drawOnboarding()
		}
	}

}
