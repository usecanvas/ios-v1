//
//  AlertController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class AlertController: UIAlertController {

	// MARK: - Properties

	/// Used when return is pressed while the controller is showing
	var primaryAction: (Void -> Void)?


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand]? {
		return (super.keyCommands ?? []) + [
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: #selector(cancel)),
			UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(selectFirstAction))
		]
	}


	// MARK: - UIViewController

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		adjustSubviews([view])
	}


	// MARK: - Actions

	func cancel(sender: AnyObject?) {
		dismissViewControllerAnimated(true, completion: nil)
	}

	func selectFirstAction(sender: AnyObject?) {
		dismissViewControllerAnimated(true) {
			self.primaryAction?()
		}
	}


	// MARK: - Private

	private func adjustSubviews(subviews: [UIView]) {
		for subview in subviews {
			if let label = subview as? UILabel {
				adjustLabel(label)
			} else if subview.bounds.height > 0 && subview.bounds.height <= 1 {
				subview.backgroundColor = Swatch.border
			}

			adjustSubviews(subview.subviews)
		}
	}

	private func adjustLabel(label: UILabel) {
		for action in actions {
			if label.text == title {
				label.attributedText = NSAttributedString(string: label.text ?? "", attributes: [
					NSFontAttributeName: label.font,
					NSForegroundColorAttributeName: Swatch.darkGray
				])
				return
			}

			if label.text == action.title {
				switch action.style {
				case .Default, .Cancel:
					label.attributedText = NSAttributedString(string: label.text ?? "", attributes: [
						NSFontAttributeName: label.font,
						NSForegroundColorAttributeName: Swatch.brand
					])
				case .Destructive:
					label.attributedText = NSAttributedString(string: label.text ?? "", attributes: [
						NSFontAttributeName: label.font,
						NSForegroundColorAttributeName: Swatch.destructive
					])
				}
			}
		}
	}
}
