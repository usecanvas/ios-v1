//
//  AlertController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

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
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "cancel:"),
			UIKeyCommand(input: "\r", modifierFlags: [], action: "selectFirstAction:")
		]
	}


	// MARK: - Actions

	func cancel(sender: AnyObject?) {
		dismissViewControllerAnimated(true, completion: nil)
	}

	func selectFirstAction(sender: AnyObject?) {
		primaryAction?()
		dismissViewControllerAnimated(true, completion: nil)
	}
}
