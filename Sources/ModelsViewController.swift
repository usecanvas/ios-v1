//
//  ModelsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import Static

// TODO: Localize this class
class ModelsViewController: TableViewController {

	// MARK: - Properties

	var loading = false {
		didSet {
			if !loading {
				refreshControl?.endRefreshing()
			}
		}
	}

	var opening = false


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []

		if let navigationController = navigationController where navigationController.viewControllers.count > 1 {
			let previousTitle = (navigationController.viewControllers[navigationController.viewControllers.count - 2]).title
			let backTitle = previousTitle.flatMap { "Back to \($0)" } ?? "Back"

			commands += [
				UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [], action: #selector(goBack), discoverabilityTitle: backTitle),
				UIKeyCommand(input: "w", modifierFlags: [.Command], action: #selector(goBack))
			]
		}

		if canRefresh {
			commands.append(UIKeyCommand(input: "R", modifierFlags: [.Command], action: #selector(refresh), discoverabilityTitle: "Refresh"))
		}

		return commands
	}


	// MARK: - UIViewController

//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		let control = UIRefreshControl()
//		control.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
//		refreshControl = control
//	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		opening = false
		refresh()
	}


	// MARK: - Configuration

	var canRefresh = true


	// MARK: - Actions

	func refresh() {
		// Subclasses should override this
	}


	// MARK: - Private

	@objc private func goBack() {
		navigationController?.popViewControllerAnimated(true)
	}
}
