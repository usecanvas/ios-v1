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
import Longhouse
import AMScrollingNavbar

class EditorViewController: UIViewController, Accountable {
	
	// MARK: - Properties

	var account: Account
	let canvas: Canvas

	let textStorage = TextStorage(theme: LightTheme())
	private let textView: TextView
	private let longhouse = Longhouse(serverURL: NSURL(string: "wss://presence.usecanvas.com/")!)
	private let presenceBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)


	// MARK: - Initializers

	init(account: Account, canvas: Canvas) {
		self.account = account
		self.canvas = canvas

		textView = TextView(textStorage: textStorage)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.keyboardDismissMode = .Interactive

		super.init(nibName: nil, bundle: nil)

		longhouse.delegate = self
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

		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:"),
			presenceBarButtonItem
		]

		textView.delegate = self
		view.addSubview(textView)

		textStorage.connect(accessToken: account.accessToken, collectionID: canvas.collectionID, canvasID: canvas.ID) { [weak self] webView in
			guard let this = self else { return }
			this.longhouse.join(this.canvas.ID, identity: this.account.user.email)
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
		let padding = max(16, (textView.bounds.width - maxWidth) / 2)
		textView.textContainerInset = UIEdgeInsets(top: 16, left: padding, bottom: 32, right: padding)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let navigationController = navigationController as? ScrollingNavigationController {
			navigationController.followScrollView(textView, delay: 0.0)
		}
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		if let navigationController = navigationController as? ScrollingNavigationController {
			navigationController.stopFollowingScrollView()
			navigationController.showNavbar(animated: animated)
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


extension EditorViewController: LonghouseDelegate {
	func longhouse(longhouse: Longhouse, didConnectWithID ID: String) {}
	func longhouse(longhouse: Longhouse, failedToConnectWithError error: ErrorType) {}
	func longhouse(longhouse: Longhouse, didReceiveEvent event: Event, withClient client: Client) {}

	func longhouseDidUpdateConnectedClients(longhouse: Longhouse) {
		presenceBarButtonItem.title = "\(longhouse.connectedClients.count)"
	}
}
