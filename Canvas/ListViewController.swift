//
//  ListViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static

class ListViewController<T: Equatable>: TableViewController {

	// MARK: - Properties

	var arrangedItems = [T]() {
		didSet {
			reloadRows()
		}
	}

	var selectedItem: T?

	var loading = false {
		didSet {
			if !loading {
				refreshControl?.endRefreshing()
			}
		}
	}


	// MARK: - Initializers

	init() {
		super.init(nibName: nil, bundle: nil)
	}


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []
		commands += [
			UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: "selectPrevious", discoverabilityTitle: "Previous  \(itemTypeName)"),
			UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: "selectNext", discoverabilityTitle: "Next  \(itemTypeName)"),
			UIKeyCommand(input: "\r", modifierFlags: [], action: "openSelected", discoverabilityTitle: "Open \(itemTypeName)"),
			UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: "openSelected"),
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "clearSelected", discoverabilityTitle: "Clear Selection")
		]

		if canRefresh {
			commands.append(UIKeyCommand(input: "R", modifierFlags: [.Command], action: "refresh", discoverabilityTitle: "Refresh"))
		}

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let control = UIRefreshControl()
		control.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
		refreshControl = control
	}


	// MARK: - Configuration

	var itemTypeName: String {
		fatalError("Subclasses must override this method.")
	}

	var canRefresh = true

	func rowForItem(item: T, isSelected: Bool) -> Row {
		fatalError("Subclasses must override this method.")
	}

	func selectItem(item: T) {
		// Do nothing. Subclasses are encouraged to override this.
	}


	// MARK: - Actions

	func refresh() {
		fatalError("Subclasses must override this method.")
	}


	// MARK: - Private

	private func rowForItem(item: T) -> Row {
		let selected = selectedItem.flatMap { $0 == item } ?? false
		return rowForItem(item, isSelected: selected)

	}

	@objc private func selectPrevious() {
		guard let selectedItem = selectedItem, index = arrangedItems.indexOf({ $0 == selectedItem }) else {
			self.selectedItem = arrangedItems.first
			return
		}

		if index == 0 {
			return
		}

		self.selectedItem = arrangedItems[index.predecessor()]
	}

	@objc private func selectNext() {
		guard let selectedItem = selectedItem, index = arrangedItems.indexOf({ $0 == selectedItem }) else {
			self.selectedItem = arrangedItems.first
			return
		}

		if index == arrangedItems.count - 1 {
			return
		}

		self.selectedItem = arrangedItems[index.successor()]

	}

	@objc private func openSelected() {
		guard let item = selectedItem ?? arrangedItems.first else { return }
		selectItem(item)
	}

	@objc private func clearSelected() {
		selectedItem = nil
	}


	// MARK: - Private

	private func reloadRows() {
		dataSource.sections = [
			Section(rows: arrangedItems.map { rowForItem($0) })
		]
	}
}
