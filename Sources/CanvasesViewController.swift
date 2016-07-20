//
//  CanvasesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 12/8/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore
import CanvasKit
import CanvasNative

class CanvasesViewController: ModelsViewController, Accountable {

	// MARK: - Properties

	var account: Account


	// MARK: - Initializers

	init(account: Account, style: UITableViewStyle = .Plain) {
		self.account = account
		super.init(style: style)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rowHeight = 72

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
	}


	// MARK: - ModelsViewController

	func openCanvas(canvas: Canvas) {
		guard !opening else { return }

		if let editor = currentEditor() where editor.canvas == canvas {
			return
		}

		opening = true

		if !CanvasNative.supports(nativeVersion: canvas.nativeVersion) {
			if let indexPath = tableView.indexPathForSelectedRow {
				tableView.deselectRowAtIndexPath(indexPath, animated: true)
			}

			let alert = UIAlertController(title: LocalizedString.UnsupportedTitle.string, message: LocalizedString.UnsupportedMessage.string, preferredStyle: .Alert)

			#if !APP_STORE
			alert.addAction(UIAlertAction(title: LocalizedString.CheckForUpdatesButton.string, style: .Default, handler: { _ in
				UIApplication.sharedApplication().openURL(config.updatesURL)
			}))
			#endif

			alert.addAction(UIAlertAction(title: LocalizedString.OpenInSafariButton.string, style: .Default, handler: { _ in
				guard let url = canvas.url else { return }
				UIApplication.sharedApplication().openURL(url)
			}))
			alert.addAction(UIAlertAction(title: LocalizedString.Cancel.string, style: .Cancel, handler: nil))

			opening = false
			presentViewController(alert, animated: true, completion: nil)

			return
		}

		Analytics.track(.OpenedCanvas)
		let viewController = EditorViewController(account: account, canvas: canvas)
		showDetailViewController(NavigationController(rootViewController: viewController), sender: self)

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.opening = false
		}
	}


	// MARK: - Utilities

	func currentEditor() -> EditorViewController? {
		guard let splitViewController = splitViewController where splitViewController.viewControllers.count == 2 else { return nil }
		return (splitViewController.viewControllers.last as? UINavigationController)?.topViewController as? EditorViewController
	}

	func rowForCanvas(canvas: Canvas) -> Row {
		var row = canvas.row
		row.selection = { [weak self] in self?.openCanvas(canvas) }
		return row
	}
}
