//
//  EditorViewController+Actions.swift
//  Canvas
//
//  Created by Sam Soffes on 5/5/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

extension EditorViewController {
	func closeNavigationControllerModal() {
		navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}

	func close(sender: UIAlertAction? = nil) {
		NSNotificationCenter.defaultCenter().postNotificationName(EditorViewController.willCloseNotificationName, object: nil)
		dismissDetailViewController(self)
	}
	
	func dismissKeyboard(sender: AnyObject?) {
		textView.resignFirstResponder()
	}

	private func present(actionSheet actionSheet: UIViewController, sender: AnyObject?, animated: Bool = true, completion: (() -> Void)? = nil) {
		if let popover = actionSheet.popoverPresentationController {
			if let button = sender as? UIBarButtonItem {
				popover.barButtonItem = button
			} else if let sourceView = sender as? UIView {
				popover.sourceView = sourceView
			} else {
				popover.sourceView = view
			}
		}

		presentViewController(actionSheet, animated: animated, completion: completion)
	}

	func more(sender: AnyObject?) {
		// If you can't edit the document, all you can do is share.
		if !canvas.isWritable {
			share(sender)
			return
		}

		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

		// Archive/unarchive
		if canvas.archivedAt == nil {
			actionSheet.addAction(UIAlertAction(title: LocalizedString.ArchiveButton.string, style: .Destructive, handler: showArchive))
		} else {
			actionSheet.addAction(UIAlertAction(title: LocalizedString.UnarchiveButton.string, style: .Default, handler: unarchive))
		}

		// Enable/disable public edits
		if canvas.isPublicWritable {
			actionSheet.addAction(UIAlertAction(title: LocalizedString.DisablePublicEditsButton.string, style: .Default, handler: disablePublicEdits))
		} else {
			actionSheet.addAction(UIAlertAction(title: LocalizedString.EnablePublicEditsButton.string, style: .Default, handler: enablePublicEdits))
		}

		// Share
		actionSheet.addAction(UIAlertAction(title: LocalizedString.ShareButton.string, style: .Default) { [weak self] _ in
			self?.share(sender)
		})

		actionSheet.addAction(UIAlertAction(title: LocalizedString.Cancel.string, style: .Cancel, handler: nil))

		present(actionSheet: actionSheet, sender: sender)
	}

	func showArchive(sender: AnyObject?) {
		let alert = UIAlertController(title: LocalizedString.ArchiveCanvasTitle.string, message: LocalizedString.ArchiveCanvasMessage.string, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: LocalizedString.DeleteButton.string, style: .Destructive, handler: destroy))
		alert.addAction(UIAlertAction(title: LocalizedString.ArchiveButton.string, style: .Default, handler: archive))
		alert.addAction(UIAlertAction(title: LocalizedString.Cancel.string, style: .Cancel, handler: nil))
		presentViewController(alert, animated: true, completion: nil)
	}

	func archive(sender: AnyObject?) {
		APIClient(account: account).archiveCanvas(canvasID: canvas.id)
		close()
	}

	func unarchive(sender: AnyObject?) {
		APIClient(account: account).unarchiveCanvas(canvasID: canvas.id) { [weak self] result in
			switch result {
			case .Success(_): self?.showBanner(text: "Unarchived canvas", style: .success) // TODO: Localize
			case .Failure(_): self?.showBanner(text: "Failed to unarchive canvas", style: .failure) // TODO: Localize
			}
		}
	}

	func destroy(sender: AnyObject?) {
		APIClient(account: account).destroyCanvas(canvasID: canvas.id)
		close()
	}

	func enablePublicEdits(sender: AnyObject?) {
		APIClient(account: account).enablePublicEdits(canvasID: canvas.id) { [weak self] result in
			dispatch_async(dispatch_get_main_queue()) {
				switch result {
				case .Success(let canvas):
					self?.canvas = canvas
					self?.showBanner(text: "Enabled public edits", style: .success) // TODO: Localize
				case .Failure(_):
					self?.showBanner(text: "Failed to enable public edits", style: .failure) // TODO: Localize
				}
			}
		}
	}

	func disablePublicEdits(sender: AnyObject?) {
		APIClient(account: account).disablePublicEdits(canvasID: canvas.id) { [weak self] result in
			dispatch_async(dispatch_get_main_queue()) {
				switch result {
				case .Success(let canvas):
					self?.canvas = canvas
					self?.showBanner(text: "Disabled public edits", style: .success) // TODO: Localize
				case .Failure(_):
					self?.showBanner(text: "Failed to disable public edits", style: .failure) // TODO: Localize
				}
			}
		}
	}
	
	func share(sender: AnyObject?) {
		dismissKeyboard(sender)
		
		guard let URL = canvas.url else { return }

		let activities = [
			SafariActivity(),
			ChromeActivity(),
			CopyLinkActivity(),
			CopyRepresentationActivity(representation: .markdown),
			CopyRepresentationActivity(representation: .html),
			CopyRepresentationActivity(representation: .json)
		]

		let actionSheet = UIActivityViewController(activityItems: [URL], applicationActivities: activities)
		actionSheet.excludedActivityTypes = [
			UIActivityTypeAddToReadingList,
			UIActivityTypeCopyToPasteboard
		]

		present(actionSheet: actionSheet, sender: sender)
	}
	
	func check() {
		textController.toggleChecked()
	}
	
	func indent() {
		textController.indent()
	}
	
	func outdent() {
		textController.outdent()
	}
	
	func bold() {
		textController.bold()
	}
	
	func italic() {
		textController.italic()
	}
	
	func inlineCode() {
		textController.inlineCode()
	}
	
	func insertLineAfter() {
		textController.insertLineAfter()
	}
	
	func insertLineBefore() {
		textController.insertLineBefore()
	}
	
	func deleteLine() {
		textController.deleteLine()
	}

	func swapLineUp() {
		textController.swapLineUp()
	}

	func swapLineDown() {
		textController.swapLineDown()
	}
	
	func reload(sender: UIAlertAction? = nil) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		title = LocalizedString.Connecting.string
		textController.connect()
	}
}
