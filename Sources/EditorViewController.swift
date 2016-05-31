//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import CanvasKit
import CanvasText
import CanvasNative
import SentrySwift

final class EditorViewController: UIViewController, Accountable {
	
	// MARK: - Properties

	static let willCloseNotificationName = "EditorViewController.willCloseNotificationName"

	var account: Account
	let canvas: Canvas

	let textController: TextController
	let textView: CanvasTextView

	private var usingKeyboard = false
	private var scrollPosition: CGPoint?
	private var autocompleteEnabled = false {
		didSet {
			if oldValue == autocompleteEnabled {
				return
			}

			textView.autocapitalizationType = autocompleteEnabled ? .Sentences : .None
			textView.autocorrectionType = autocompleteEnabled ? .Default : .No
			textView.spellCheckingType = autocompleteEnabled ? .Default : .No

			// Make the change actually take effect.
			textView.resignFirstResponder()
			textView.becomeFirstResponder()
		}
	}


	// MARK: - Initializers

	init(account: Account, canvas: Canvas) {
		self.account = account
		self.canvas = canvas

		textController = TextController(
			serverURL: config.realtimeURL,
			accessToken: account.accessToken,
			organizationID: canvas.organization.ID,
			canvasID: canvas.ID
		)

		let textView = CanvasTextView(frame: .zero, textContainer: textController.textContainer)
		textView.translatesAutoresizingMaskIntoConstraints = false
		self.textView = textView
		
		super.init(nibName: nil, bundle: nil)
		
		textController.connectionDelegate = self
		textController.displayDelegate = self
		textController.annotationDelegate = textView
		textView.textController = textController
		textView.delegate = self
		textView.formattingDelegate = self
		textView.editable = false

		UIDevice.currentDevice().batteryMonitoringEnabled = true
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePreventSleep), name: NSUserDefaultsDidChangeNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePreventSleep), name: UIApplicationDidBecomeActiveNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePreventSleep), name: UIDeviceBatteryStateDidChangeNotification, object: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		var commands: [UIKeyCommand] = [
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: #selector(dismissKeyboard)),
			UIKeyCommand(input: "w", modifierFlags: [.Command], action: #selector(close), discoverabilityTitle: LocalizedString.CloseCommand.string),

//			UIKeyCommand(input: "b", modifierFlags: [.Command], action: #selector(bold), discoverabilityTitle: LocalizedString.BoldCommand.string),
//			UIKeyCommand(input: "i", modifierFlags: [.Command], action: #selector(italic), discoverabilityTitle: LocalizedString.ItalicCommand.string),
//			UIKeyCommand(input: "d", modifierFlags: [.Command], action: #selector(inlineCode), discoverabilityTitle: LocalizedString.InlineCodeCommand.string),

			UIKeyCommand(input: "]", modifierFlags: [.Command], action: #selector(indent), discoverabilityTitle: LocalizedString.IndentCommand.string),
			UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(indent)),
			UIKeyCommand(input: "[", modifierFlags: [.Command], action: #selector(outdent), discoverabilityTitle: LocalizedString.OutdentCommand.string),
			UIKeyCommand(input: "\t", modifierFlags: [.Shift], action: #selector(outdent)),

			UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [.Command, .Control], action: #selector(swapLineUp), discoverabilityTitle: LocalizedString.SwapLineUpCommand.string),
			UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [.Command, .Control], action: #selector(swapLineDown), discoverabilityTitle: LocalizedString.SwapLineDownCommand.string)
		]

		let checkTitle: String
		if let block = textController.focusedBlock as? ChecklistItem where block.state == .Checked {
			checkTitle = LocalizedString.MarkAsUncheckedCommand.string
		} else {
			checkTitle = LocalizedString.MarkAsCheckedCommand.string
		}

		let check = UIKeyCommand(input: "u", modifierFlags: [.Command, .Shift], action: #selector(self.check), discoverabilityTitle: checkTitle)
		commands.append(check)

		commands += [
			UIKeyCommand(input: "k", modifierFlags: [.Control, .Shift], action: #selector(deleteLine), discoverabilityTitle: LocalizedString.DeleteLineCommand.string),
			UIKeyCommand(input: "\r", modifierFlags: [.Command, .Shift], action: #selector(insertLineBefore), discoverabilityTitle: LocalizedString.InsertLineBeforeCommand.string),
			UIKeyCommand(input: "\r", modifierFlags: [.Command], action: #selector(insertLineAfter), discoverabilityTitle: LocalizedString.InsertLineAfterCommand.string)
		]
		
		return commands
	}

	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()

		title = LocalizedString.Connecting.string
		view.backgroundColor = Color.white

		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(share))
		]

		textView.delegate = self
		view.addSubview(textView)

		textController.connect()
		
		NSLayoutConstraint.activateConstraints([
			textView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			textView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			textView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])

		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: textView)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let maxWidth: CGFloat = 640
		let horizontalPadding = max(16 - textView.textContainer.lineFragmentPadding, (textView.bounds.width - maxWidth) / 2)
		let topPadding = max(16, min(32, horizontalPadding - 4)) // Subtract 4 for title line height
		textView.textContainerInset = UIEdgeInsets(top: topPadding, left: horizontalPadding, bottom: 32, right: horizontalPadding)
		textController.textContainerInset = textView.textContainerInset
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		updatePreventSleep()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.sharedApplication().idleTimerDisabled = false
		textView.resignFirstResponder()
	}
	
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		textController.traitCollection = traitCollection
	}


	// MARK: - Private

	@objc private func keyboardWillChangeFrame(notification: NSNotification?) {
		guard let notification = notification,
			value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
		else { return }

		let frame = textView.frame.intersect(view.convertRect(value.CGRectValue(), fromView: nil))
		var insets = textView.contentInset
		insets.bottom = frame.height

		textView.contentInset = insets
		textView.scrollIndicatorInsets = insets
	}

	@objc private func updatePreventSleep() {
		let application = UIApplication.sharedApplication()
		guard let preference = NSUserDefaults.standardUserDefaults().stringForKey("PreventSleep") else {
			application.idleTimerDisabled = false
			return
		}

		if preference == "Always" {
			application.idleTimerDisabled = true
		} else if preference == "WhilePluggedIn" {
			let state = UIDevice.currentDevice().batteryState
			application.idleTimerDisabled = state == .Charging || state == .Full
		} else {
			application.idleTimerDisabled = false
		}
	}
	
	private func imgixURL(URL: NSURL) -> NSURL? {
		let defaultParameters = [
			NSURLQueryItem(name: "dpr", value: "\(Int(traitCollection.displayScale))"),
			NSURLQueryItem(name: "fm", value: "jpg"),
			NSURLQueryItem(name: "q", value: "80"),
			NSURLQueryItem(name: "cs", value: "adobergb1998"),
			NSURLQueryItem(name: "w", value: "\(Int(view.bounds.width))")
		]
		
		// Uploaded image
		let uploadPrefix = "https://canvas-files-prod.s3.amazonaws.com/uploads/"
		if URL.absoluteString.hasPrefix(uploadPrefix) {
			let imgix = Imgix(host: config.imgixUploadHost, secret: config.imgixUploadSecret, defaultParameters: defaultParameters)
			let path = (URL.absoluteString as NSString).substringFromIndex((uploadPrefix as NSString).length)
			return imgix.signPath(path)
		}
		
		// Linked image
		let imgix = Imgix(host: config.imgixProxyHost, secret: config.imgixProxySecret, defaultParameters: defaultParameters)
		let path = URL.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())
		return path.flatMap { imgix.signPath($0) }
	}

	private func updateTitlePlaceholder() {
		let title = textController.currentDocument.blocks.first as? Title
		textView.placeholderLabel.hidden = title.flatMap { $0.visibleRange.length > 0 } ?? false
	}

	private func updateTitleTypingAttributes() {
		if textView.selectedRange.location == 0 {
			textView.typingAttributes = textController.theme.titleAttributes
		}
	}

	private func updateAutoCompletion() {
		autocompleteEnabled = !textController.isCodeFocused
	}
}


extension EditorViewController: TintableEnvironment {
	var preferredTintColor: UIColor {
		return canvas.organization.color?.color ?? Color.brand
	}
}


extension EditorViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let textRange = textView.characterRangeAtPoint(location) else { return nil }

		let range = NSRange(
			location: textView.offsetFromPosition(textView.beginningOfDocument, toPosition: textRange.start),
			length: textView.offsetFromPosition(textRange.start, toPosition: textRange.end)
		)

		let document = textController.currentDocument
		let nodes = document.nodesIn(backingRange: document.backingRange(presentationRange: range))

		guard let index = nodes.indexOf({ $0 is Link }),
			link = nodes[index] as? Link,
			URL = link.URL(backingString: document.backingString)
		where URL.scheme == "http" || URL.scheme == "https"
		else { return nil }

		previewingContext.sourceRect = textView.firstRectForRange(textRange)

		return WebViewController(URL: URL)
	}

	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		presentViewController(viewControllerToCommit, animated: false, completion: nil)
	}
}


extension EditorViewController: UITextViewDelegate {
	func textViewDidChangeSelection(textView: UITextView) {
		let selection: NSRange? = !textView.isFirstResponder() && textView.selectedRange.length == 0 ? nil : textView.selectedRange
		textController.setPresentationSelectedRange(selection)
		updateTitleTypingAttributes()
		updateAutoCompletion()
	}

	func textViewDidBeginEditing(textView: UITextView) {
		usingKeyboard = true
		updateTitleTypingAttributes()
	}
	
	func textViewDidEndEditing(textView: UITextView) {
		textController.setPresentationSelectedRange(nil)
	}
}


extension EditorViewController: TextControllerDisplayDelegate {
	func textController(textController: TextController, didUpdateSelectedRange selectedRange: NSRange) {
		if !NSEqualRanges(textView.selectedRange, selectedRange) {
			textView.selectedRange = selectedRange
		}

		updateTitleTypingAttributes()
	}

	func textController(textController: TextController, didUpdateTitle title: String?) {
		self.title = title ?? LocalizedString.Untitled.string
		updateTitlePlaceholder()
	}

	func textControllerWillProcessRemoteEdit(textController: TextController) {
		scrollPosition = textView.contentOffset
	}

	func textControllerDidProcessRemoteEdit(textController: TextController) {
		if let scrollPosition = scrollPosition {
			textView.contentOffset = scrollPosition
			self.scrollPosition = nil
		}

		updateAutoCompletion()
	}
	
	func textController(textController: TextController, URLForImage block: Image) -> NSURL? {
		return imgixURL(block.url)
	}
}


extension EditorViewController: TextControllerConnectionDelegate {
	func textController(textController: TextController, willConnectWithWebView webView: WKWebView) {
		webView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
		view.addSubview(webView)
	}

	func textControllerDidConnect(textController: TextController) {
		if canvas.isWritable {
			textView.editable = true
		}

		updateTitlePlaceholder()

		if textView.editable && (usingKeyboard || textView.text.isEmpty) {
			textView.becomeFirstResponder()
		}
	}

	func textController(textController: TextController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		textView.editable = false
		
		var dictionary = [String: AnyObject]()
		var message = errorMessage ?? "Unknown error."
		message += " "

		if let lineNumber = lineNumber {
			dictionary["line_number"] = lineNumber
			message += "\(lineNumber):"
		} else {
			message += "?:"
		}

		if let columnNumber = columnNumber {
			dictionary["column_number"] = columnNumber
			message += "\(columnNumber)"
		} else {
			message += "?"
		}

		let event = Event.build("CanvasNativeWrapper Error") {
			$0.level = .Error

			var dictionary = [String: AnyObject]()

			if let errorMessage = errorMessage {
				dictionary["error_message"] = errorMessage
			}

			if let lineNumber = lineNumber {
				dictionary["line_number"] = lineNumber
			}

			if let columnNumber = columnNumber {
				dictionary["column_number"] = columnNumber
			}

			if !dictionary.isEmpty {
				$0.extra = dictionary
			}
		}

		SentryClient.shared?.captureEvent(event)

		let completion = { [weak self] in
			self?.textController.disconnect(reason: "wrapper-error")
		}

		#if INTERNAL
			let alert = UIAlertController(title: "CanvasNativeWrapper Error", message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: LocalizedString.Okay.string, style: .Cancel) { _ in
				completion()
			})
			presentViewController(alert, animated: true, completion: nil)
		#else
			completion()
		#endif
	}

	func textController(textController: TextController, didDisconnectWithErrorMessage errorMessage: String?) {
		title = LocalizedString.Disconnected.string

		let state = usingKeyboard
		textView.editable = false
		usingKeyboard = state

		let message: String
		if errorMessage == "wrapper-error" {
			message = "We’re still a bit buggy and hit a wall. We’ve reported the error."
		} else {
			message = "The connection to Canvas was lost."
		}

		let alert = UIAlertController(title: "Disconnected", message: message, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Close Canvas", style: .Destructive, handler: close))
		alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: reload))
		presentViewController(alert, animated: true, completion: nil)
	}
}


extension EditorViewController: CanvasTextViewFormattingDelegate {
	func textViewDidToggleBoldface(textView: CanvasTextView, sender: AnyObject?) {
		bold()
	}

	func textViewDidToggleItalics(textView: CanvasTextView, sender: AnyObject?) {
		italic()
	}
}
