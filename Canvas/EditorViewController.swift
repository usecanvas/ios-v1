//
//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import CanvasText
import AMScrollingNavbar

class EditorViewController: UIViewController, Accountable {
	
	// MARK: - Properties

	var account: Account
	let canvas: Canvas

	let textStorage = TextStorage(theme: LightTheme())
	let textView: TextView


	// MARK: - Initializers

	init(account: Account, canvas: Canvas) {
		self.account = account
		self.canvas = canvas

		textView = TextView(textStorage: textStorage)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.keyboardDismissMode = .Interactive

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		return [
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "dismissKeyboard:")
		]
	}

	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Color.white

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:")

		textView.delegate = self
		view.addSubview(textView)

		textStorage.connect(accessToken: account.accessToken, collectionID: canvas.collectionID, canvasID: canvas.ID) { [weak self] webView in
			self?.view.addSubview(webView)
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
		let padding = max(16, (textView.bounds.width - maxWidth) / 2)
		textView.textContainerInset = UIEdgeInsets(top: 16, left: padding, bottom: 32, right: padding)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let navigationController = self.navigationController as? ScrollingNavigationController {
			// TODO: This should be the height of the DocHeading node
			navigationController.followScrollView(textView, delay: 0.0)
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)

		if let navigationController = self.navigationController as? ScrollingNavigationController {
			navigationController.stopFollowingScrollView()
		}
	}


	// MARK: - Actions

	@objc private func dismissKeyboard(sender: AnyObject?) {
		textView.resignFirstResponder()
	}

	@objc private func share(sender: AnyObject?) {
		guard let URL = NSURL(string: "https://usecanvas.com/\(canvas.collectionID)/-/\(canvas.shortID)") else { return }
		let activities = [SafariActivity(), ChromeActivity()]
		let viewController = UIActivityViewController(activityItems: [URL], applicationActivities: activities)
		presentViewController(viewController, animated: true, completion: nil)
	}
}


extension EditorViewController: UITextViewDelegate {
	func textViewDidChangeSelection(textView: UITextView) {
		textStorage.backingSelection = textStorage.displayRangeToBackingRange(textView.selectedRange)
	}

	func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
		if let navigationController = self.navigationController as? ScrollingNavigationController {
			navigationController.showNavbar(animated: true)
		}
		return true
	}
}
