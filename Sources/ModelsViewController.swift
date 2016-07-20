//
//  ModelsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import Static
import PullToRefresh

// TODO: Localize this class
class ModelsViewController: TableViewController {

	// MARK: - Properties

	var loading = false {
		didSet {
			UIApplication.sharedApplication().networkActivityIndicatorVisible = loading

			if loading {
				refreshView.startRefreshing(false)
			} else {
				refreshView.finishRefreshing()
			}
		}
	}

	var opening = false

	let refreshView = RefreshView()


	// MARK: - Initializers

	override init(style: UITableViewStyle) {
		super.init(style: style)

		refreshView.expandedHeight = 48 + 32
		refreshView.delegate = self
		refreshView.contentView = RefreshContentView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		refreshView.scrollView = nil
	}


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

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		opening = false
		refresh()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if canRefresh && refreshView.scrollView == nil {
			refreshView.scrollView = tableView
		}

		refreshView.defaultContentInsets = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
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


extension ModelsViewController: RefreshViewDelegate {
	func refreshViewDidStartRefreshing(refreshView: RefreshView) {
		refresh()
	}

	func refreshViewShouldStartRefreshing(refreshView: RefreshView) -> Bool { return true }
	func refreshViewDidFinishRefreshing(refreshView: RefreshView) {}
	func lastUpdatedAtForRefreshView(refreshView: RefreshView) -> NSDate? { return nil }
	func refreshView(refreshView: RefreshView, didUpdateContentInset contentInset: UIEdgeInsets) {}
	func refreshView(refreshView: RefreshView, willTransitionTo to: RefreshView.State, from: RefreshView.State, animated: Bool) {}
	func refreshView(refreshView: RefreshView, didTransitionTo to: RefreshView.State, from: RefreshView.State, animated: Bool) {}
}
