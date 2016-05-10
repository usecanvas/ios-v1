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

	var account: Account
	let canvas: Canvas

	let textController: TextController
	let textView: UITextView

	private var scrollPosition: CGPoint?
	private var ignoreSelectionChange = false


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

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePreventSleep), name: NSUserDefaultsDidChangeNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePreventSleep), name: UIApplicationDidBecomeActiveNotification, object: nil)
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
			UIKeyCommand(input: "\t", modifierFlags: [.Shift], action: #selector(outdent))
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

		title = LocalizedString.Loading.string
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
		let padding = max(16 - textView.textContainer.lineFragmentPadding, (textView.bounds.width - maxWidth) / 2)
		textView.textContainerInset = UIEdgeInsets(top: 16, left: padding, bottom: 32, right: padding)
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
		if NSUserDefaults.standardUserDefaults().boolForKey("PreventSleep") {
			UIApplication.sharedApplication().idleTimerDisabled = true
		}
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
			link = nodes[index] as? Link
		else { return nil }

		let string = (document.backingString as NSString).substringWithRange(link.urlRange)
		guard let URL = NSURL(string: string) else { return nil }

		previewingContext.sourceRect = textView.firstRectForRange(textRange)

		return WebViewController(URL: URL)
	}

	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		presentViewController(viewControllerToCommit, animated: false, completion: nil)
	}
}


extension EditorViewController: UITextViewDelegate {
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		ignoreSelectionChange = true

		let empty = (textView.text as NSString).length - range.length + (text as NSString).length == 0

		if empty {
			textView.typingAttributes = textController.theme.titleAttributes
		}

		(textView as? CanvasTextView)?.placeholderLabel.hidden = !empty
		
		return true
	}
	
	func textViewDidChangeSelection(textView: UITextView) {
		let selection: NSRange? = !textView.isFirstResponder() && textView.selectedRange.length == 0 ? nil : textView.selectedRange
		textController.setPresentationSelectedRange(selection)
	}
	
	func textViewDidEndEditing(textView: UITextView) {
		textController.setPresentationSelectedRange(nil)
	}
}


extension EditorViewController: TextControllerDisplayDelegate {
	func textController(textController: TextController, didUpdateSelectedRange selectedRange: NSRange) {
		if ignoreSelectionChange {
			ignoreSelectionChange = false
			return
		}

		if !NSEqualRanges(textView.selectedRange, selectedRange) {
			textView.selectedRange = selectedRange
		}
	}

	func textController(textController: TextController, didUpdateTitle title: String?) {
		self.title = title ?? LocalizedString.Untitled.string
	}

	func textControllerWillProcessRemoteEdit(textController: TextController) {
		scrollPosition = textView.contentOffset
	}

	func textControllerDidProcessRemoteEdit(textController: TextController) {
		if let scrollPosition = scrollPosition {
			textView.contentOffset = scrollPosition
			self.scrollPosition = nil
		}
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

		if textView.text.isEmpty {
			textView.typingAttributes = textController.theme.titleAttributes
			(textView as? CanvasTextView)?.placeholderLabel.hidden = false
		}

		textView.becomeFirstResponder()
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
		textView.editable = false

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
