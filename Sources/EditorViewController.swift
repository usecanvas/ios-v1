//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import CanvasCore
import CanvasKit
import CanvasText
import CanvasNative
import SentrySwift

final class EditorViewController: UIViewController, Accountable {
	
	// MARK: - Properties

	static let willCloseNotificationName = "EditorViewController.willCloseNotificationName"

	var account: Account
	var canvas: Canvas

	let textController: TextController
	let textView: CanvasTextView
	let presenceController: PresenceController

	private var lastSize: CGSize?
	var usingKeyboard = false

	private var scrollOffset: CGFloat?
	private var ignoreLocalSelectionChange = false
	
	private let titleView: TitleView = {
		let view = TitleView()
		view.hidden = true
		return view
	}()

	let remoteCursorsController: RemoteCursorsController = {
		let controller = RemoteCursorsController()
		controller.backgroundView.translatesAutoresizingMaskIntoConstraints = false
		controller.foregroundView.translatesAutoresizingMaskIntoConstraints = false
		return controller
	}()

	var remoteCursorsTopConstraint: NSLayoutConstraint!
	
	private var autocompleteEnabled = false {
		didSet {
			if oldValue == autocompleteEnabled {
				return
			}

			textView.autocapitalizationType = autocompleteEnabled ? .Sentences : .None
			textView.autocorrectionType = autocompleteEnabled ? .Default : .No
			textView.spellCheckingType = autocompleteEnabled ? .Default : .No

			// Make the change actually take effect.
			if textView.isFirstResponder() {
				ignoreLocalSelectionChange = true
				textView.resignFirstResponder()
				textView.becomeFirstResponder()
				ignoreLocalSelectionChange = false
			}
		}
	}

	var showingParticipants = false


	// MARK: - Initializers

	init(account: Account, canvas: Canvas) {
		self.account = account
		self.canvas = canvas

		textController = TextController(
			serverURL: config.environment.realtimeURL,
			accessToken: account.accessToken,
			organizationID: canvas.organization.id,
			canvasID: canvas.id,
			theme: LightTheme(tintColor: canvas.organization.color?.uiColor ?? Swatch.brand)
		)

		let textView = CanvasTextView(frame: .zero, textContainer: textController.textContainer)
		textView.translatesAutoresizingMaskIntoConstraints = false
		self.textView = textView

		presenceController = PresenceController(account: account, serverURL: config.environment.presenceURL)
		
		super.init(nibName: nil, bundle: nil)

		presenceController.add(observer: self)

		titleView.showsLock = !canvas.isWritable
		
		textController.connectionDelegate = self
		textController.displayDelegate = self
		textController.annotationDelegate = textView
		textView.textController = textController
		textView.delegate = self
		textView.formattingDelegate = self
		textView.editable = false

		navigationItem.titleView = titleView
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: .Plain, target: self, action: #selector(more))

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
		textController.disconnect(withReason: nil)
		presenceController.disconnect()
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
		]

		if textController.focusedBlock is Listable {
			commands += [
				UIKeyCommand(input: "]", modifierFlags: [.Command], action: #selector(indent), discoverabilityTitle: LocalizedString.IndentCommand.string),
				UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(indent)),
				UIKeyCommand(input: "[", modifierFlags: [.Command], action: #selector(outdent), discoverabilityTitle: LocalizedString.OutdentCommand.string),
				UIKeyCommand(input: "\t", modifierFlags: [.Shift], action: #selector(outdent)),

				UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [.Command, .Control], action: #selector(swapLineUp), discoverabilityTitle: LocalizedString.SwapLineUpCommand.string),
				UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [.Command, .Control], action: #selector(swapLineDown), discoverabilityTitle: LocalizedString.SwapLineDownCommand.string)
			]
		}

		let checkTitle: String
		if let block = textController.focusedBlock as? ChecklistItem where block.state == .checked {
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
	
	override var title: String? {
		didSet {
			titleView.title = title ?? ""
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		title = LocalizedString.Connecting.string
		view.backgroundColor = Swatch.white

		remoteCursorsController.delegate = self
		view.addSubview(remoteCursorsController.backgroundView)

		textView.delegate = self
		view.addSubview(textView)
		view.addSubview(remoteCursorsController.foregroundView)

		textController.connect()

		remoteCursorsTopConstraint = remoteCursorsController.backgroundView.topAnchor.constraintEqualToAnchor(textView.topAnchor)

		NSLayoutConstraint.activateConstraints([
			textView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			textView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			textView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),

			remoteCursorsController.backgroundView.leadingAnchor.constraintEqualToAnchor(textView.leadingAnchor),
			remoteCursorsController.backgroundView.trailingAnchor.constraintEqualToAnchor(textView.trailingAnchor),
			remoteCursorsTopConstraint,
			remoteCursorsController.backgroundView.bottomAnchor.constraintEqualToAnchor(textView.bottomAnchor),

			remoteCursorsController.foregroundView.leadingAnchor.constraintEqualToAnchor(remoteCursorsController.backgroundView.leadingAnchor),
			remoteCursorsController.foregroundView.trailingAnchor.constraintEqualToAnchor(remoteCursorsController.backgroundView.trailingAnchor),
			remoteCursorsController.foregroundView.topAnchor.constraintEqualToAnchor(remoteCursorsController.backgroundView.topAnchor),
			remoteCursorsController.foregroundView.bottomAnchor.constraintEqualToAnchor(remoteCursorsController.backgroundView.bottomAnchor)
		])

		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: textView)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	
		// Prevent extra work if things didn't change. This method gets called more often than you'd expect.
		if view.bounds.size == lastSize { return }
		lastSize = view.bounds.size
		
		// Align title view
		if let navigationBar = navigationController?.navigationBar {
			var titleFrame = CGRect(
				x: 0,
				y: 0,
				
				// 200 seems to be when nav bar stops messing with alignment. ugh
				width: navigationBar.bounds.width - 200,
				height: navigationBar.bounds.height
			)
			titleFrame.origin.x = round((navigationBar.bounds.width - titleFrame.width) / 2)
			titleView.frame = titleFrame
		}

		let maxWidth: CGFloat = 640
		let horizontalPadding = max(16 - textView.textContainer.lineFragmentPadding, (textView.bounds.width - maxWidth) / 2)
		let topPadding = max(16, min(32, horizontalPadding - 4)) // Subtract 4 for title line height
		textView.textContainerInset = UIEdgeInsets(top: topPadding, left: horizontalPadding, bottom: 32, right: horizontalPadding)
		textController.textContainerInset = textView.textContainerInset

		// Update insertion point
		if textView.isFirstResponder() {
			ignoreLocalSelectionChange = true
			textView.resignFirstResponder()
			textView.becomeFirstResponder()
			ignoreLocalSelectionChange = false
		}

		remoteCursorsController.updateLayout()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		updatePreventSleep()
		presenceController.join(canvasID: canvas.id)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		titleView.hidden = false
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.sharedApplication().idleTimerDisabled = false
		textView.resignFirstResponder()

		if !showingParticipants {
			presenceController.leave(canvasID: canvas.id)
		}

		showingParticipants = false
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

		switch SleepPrevention.currentPreference {
		case .never:
			application.idleTimerDisabled = false
		case .whilePluggedIn:
			let state = UIDevice.currentDevice().batteryState
			application.idleTimerDisabled = state == .Charging || state == .Full
		case .always:
			application.idleTimerDisabled = true
		}
	}
	
	private func imgix(url: NSURL) -> NSURL? {
		let parameters = [
			NSURLQueryItem(name: "fit", value: "max"),
			NSURLQueryItem(name: "dpr", value: "\(Int(traitCollection.displayScale))"),
			NSURLQueryItem(name: "w", value: "\(Int(textView.textContainer.size.width))")
		]

		return ImgixController.sign(url: url, parameters: parameters, configuration: config)
	}

	func updateTitlePlaceholder() {
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

	private func updatePresenceCursor() {
		let document = textController.currentDocument
		let selection = textController.presentationSelectedRange
		presenceController.update(selection: selection, withDocument: document, canvasID: canvas.id)
	}
}


extension EditorViewController: TintableEnvironment {
	var preferredTintColor: UIColor {
		return canvas.organization.color?.uiColor ?? Swatch.brand
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
		
		// TODO: Update for inline-markers
		let nodes = document.nodesIn(backingRange: document.backingRanges(presentationRange: range)[0])

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
	// TODO: Remove this. This is a temporary solution to avoid new lines in comments.
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if !text.containsString("\n") {
			return true
		}

		var presentationRange = range

		if !text.isEmpty {
			presentationRange.length = (text as NSString).length
		}

		let backingRanges = textController.currentDocument.backingRanges(presentationRange: presentationRange)
		let markerRanges = textController.currentDocument.blocks
			.flatMap { ($0 as? InlineMarkerContainer)?.inlineMarkerPairs }
			.flatten()
			.map { $0.range }

		for backingRange in backingRanges {
			for markerRange in markerRanges {
				if NSIntersectionRange(backingRange, markerRange).length > 0 || NSMaxRange(markerRange) == backingRange.location {
					return false
				}
			}
		}

		return true
	}

	func textViewDidChangeSelection(textView: UITextView) {
		scrollOffset = nil

		let selection: NSRange? = !textView.isFirstResponder() && textView.selectedRange.length == 0 ? nil : textView.selectedRange
		textController.setPresentationSelectedRange(selection)
		updateTitleTypingAttributes()
		updateAutoCompletion()
		
		if NSEqualRanges(textView.selectedRange, NSRange(location: 0, length: 0)) {
			textView.typingAttributes = textController.theme.titleAttributes
		}

		updatePresenceCursor()
	}

	func textViewDidBeginEditing(textView: UITextView) {
		usingKeyboard = true
		updateTitleTypingAttributes()
	}
	
	func textViewDidEndEditing(textView: UITextView) {
		if ignoreLocalSelectionChange {
			return
		}
		
		textController.setPresentationSelectedRange(nil)
	}
	
	func textViewDidChange(textView: UITextView) {
		textController.applyStyles()
	}

	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		scrollOffset = nil
	}

	func scrollViewDidScroll(scrollView: UIScrollView) {
		remoteCursorsTopConstraint.constant = -scrollView.contentOffset.y
	}
}


extension EditorViewController: TextControllerDisplayDelegate {
	func textController(textController: TextController, didUpdateSelectedRange selectedRange: NSRange) {
		// Defer to after editing completes or UITextView will misplace already queued edits
		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			guard let textView = self?.textView else { return }

			if !NSEqualRanges(textView.selectedRange, selectedRange) {
				textView.selectedRange = selectedRange
				self?.updatePresenceCursor()
			}

			if let previousPositionY = self?.scrollOffset, let position = textView.positionFromPosition(textView.beginningOfDocument, offset: textView.selectedRange.location) {
				let currentPositionY = textView.caretRectForPosition(position).minY
				textView.contentOffset = CGPoint(x: 0, y: textView.contentOffset.y + currentPositionY - previousPositionY)
				self?.scrollOffset = nil
			}

			self?.updateTitleTypingAttributes()
		}
	}

	func textController(textController: TextController, didUpdateTitle title: String?) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		self.title = title ?? LocalizedString.Untitled.string
		updateTitlePlaceholder()
	}

	func textControllerWillProcessRemoteEdit(textController: TextController) {
		guard !textView.dragging, let position = textView.positionFromPosition(textView.beginningOfDocument, offset: textView.selectedRange.location) else { return }
		scrollOffset = textView.caretRectForPosition(position).minY
	}

	func textControllerDidProcessRemoteEdit(textController: TextController) {
		updateAutoCompletion()
	}
	
	func textController(textController: TextController, URLForImage block: Image) -> NSURL? {
		return block.url.flatMap { imgix($0) }
	}
	
	func textControllerDidUpdateFolding(textController: TextController) {}

	func textControllerDidLayoutText(textController: TextController) {
		if remoteCursorsController.enabled {
			return
		}

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.remoteCursorsController.enabled = true
		}
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
