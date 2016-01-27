
//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import CanvasText

final class EditorViewController: UIViewController, Accountable {
	
	// MARK: - Properties

	var account: Account
	let canvas: Canvas

	let textStorage = CanvasTextStorage(theme: LightTheme())
	private let textView: CanvasTextView
	private let presenceBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
	private var ignoreSelectionChange = false


	// MARK: - Initializers

	init(account: Account, canvas: Canvas) {
		self.account = account
		self.canvas = canvas

		textView = CanvasTextView(textStorage: textStorage)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.contentInset = .zero

		super.init(nibName: nil, bundle: nil)

		textStorage.selectionDelegate = self

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePreventSleep", name: NSUserDefaultsDidChangeNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePreventSleep", name: UIApplicationDidBecomeActiveNotification, object: nil)
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
		return [
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "dismissKeyboard:", discoverabilityTitle: LocalizedString.DismissKeyboardCommand.string),
			UIKeyCommand(input: "w", modifierFlags: [.Command], action: "close:", discoverabilityTitle: LocalizedString.CloseCommand.string)
		]
	}

	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Color.white

		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:"),
			presenceBarButtonItem
		]

		textView.delegate = self
		view.addSubview(textView)

		textStorage.connect(accessToken: account.accessToken, organizationID: canvas.organization.ID, canvasID: canvas.UUID, realtimeURL: realtimeURL) { [weak self] webView in
			guard let this = self else { return }
//			this.longhouse.join(this.canvas.ID, identity: this.account.user.email)
			this.view.addSubview(webView)
		}
		
		NSLayoutConstraint.activateConstraints([
			textView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			textView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			textView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let maxWidth = textStorage.theme.fontSize * 36

		let padding = max(16 - textView.textContainer.lineFragmentPadding, (textView.bounds.width - maxWidth) / 2)
		textView.textContainerInset = UIEdgeInsets(top: 16, left: padding, bottom: 32, right: padding)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if canvas.summary == nil {
			textView.becomeFirstResponder()
		}

		updatePreventSleep()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.sharedApplication().idleTimerDisabled = false
	}

	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition(nil) { [weak self] _ in
			dispatch_async(dispatch_get_main_queue()) {
				self?.textStorage.reprocess()
			}
		}

		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
	}
	

	// MARK: - Actions

	func close(sender: AnyObject) {
		navigationController?.popViewControllerAnimated(true)
	}

	func dismissKeyboard(sender: AnyObject?) {
		textView.resignFirstResponder()
	}

	func share(sender: AnyObject?) {
		guard let URL = canvas.URL else { return }
		let activities = [SafariActivity(), ChromeActivity()]
		let viewController = UIActivityViewController(activityItems: [URL], applicationActivities: activities)

		if let popover = viewController.popoverPresentationController {
			if let button = sender as? UIBarButtonItem {
				popover.barButtonItem = button
			} else {
				popover.sourceView = view
			}
		}

		presentViewController(viewController, animated: true, completion: nil)
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


extension EditorViewController: ShadowTextStorageSelectionDelegate {
	func textStorageDidUpdateSelection(textStorage: ShadowTextStorage) {
		if ignoreSelectionChange {
			ignoreSelectionChange = false
			return
		}

		if textView.selectedRange == textStorage.displaySelection {
			return
		}

		textView.selectedRange = textStorage.displaySelection
	}
}


extension EditorViewController: UITextViewDelegate {
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		ignoreSelectionChange = true
		return true
	}
	
	func textViewDidChangeSelection(textView: UITextView) {
		textStorage.backingSelection = textStorage.displayRangeToBackingRange(textView.selectedRange)
		self.textView.updateFolding()
	}
}


extension EditorViewController: TintableEnvironment {
	var preferredTintColor: UIColor {
		return canvas.organization.color.UIColor
	}
}

