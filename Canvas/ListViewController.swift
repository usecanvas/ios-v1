//
//  ListViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class ListViewController<T: Equatable>: TableViewController {

	// MARK: - Properties

	var arrangedObjects = [T]() {
		didSet {
			reloadRows()
		}
	}

	var selectedObject: T?

	var loading = false {
		didSet {
			if !loading {
				refreshControl?.endRefreshing()
			}
		}
	}


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []
		commands += [
			UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: "selectPrevious:", discoverabilityTitle: "Previous Collection"),
			UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: "selectNext:", discoverabilityTitle: "Next Collection"),
			UIKeyCommand(input: "\r", modifierFlags: [], action: "openSelected:", discoverabilityTitle: "Open Collection"),
			UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: "openSelected:"),
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "clearSelected:", discoverabilityTitle: "Clear Selection")
		]

		if self.dynamicType.canRefresh {
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

	static var objectName: String {
		// Subclasses are intended to override this
		return "Object"
	}

	static var canRefresh: Bool {
		return true
	}


	// MARK: - Actions

	func refresh() {
		// Do nothing. Subclasses are intended to override this
	}

	// MARK: - Actions

	func selectPrevious(sender: AnyObject?) {
		guard let selectedObject = selectedObject, index = arrangedObjects.indexOf({ $0 == selectedObject }) else {
			self.selectedObject = arrangedObjects.first
			return
		}

		if index == 0 {
			return
		}

		self.selectedObject = arrangedObjects[index.predecessor()]
	}

	func selectNextCollection(sender: AnyObject?) {
		guard let selectedObject = selectedObject, index = arrangedObjects.indexOf({ $0 == selectedObject }) else {
			self.selectedObject = arrangedObjects.first
			return
		}

		if index == arrangedObjects.count - 1 {
			return
		}

		self.selectedObject = arrangedObjects[index.successor()]

	}

	func openSelectedCollection(sender: AnyObject?) {
		guard let collection = selectedObject ?? arrangedObjects.first else { return }
		showCollection(collection)()
	}

	func clearSelected(sender: AnyObject?) {
		selectedObject = nil
	}


	// MARK: - Private

//	private func reloadRows() {
//		let rows = arrangedObjects.map {
//			Row(
//				text: $0.name,
//				accessory: .DisclosureIndicator,
//				selection: showCollection($0),
//				cellClass: collectionCellClass($0)
//			)
//		}
//
//		dataSource.sections = [Section(rows: rows)]
//	}
//
//	private func collectionCellClass(collection: Collection) -> CellType.Type {
//		let selected = selectedObject.flatMap { $0.ID == collection.ID } ?? false
//		return selected ? SelectedCollectionCell.self : CollectionCell.self
//	}
//
//	// TODO: Guard against pushing multiple at the same time
//	private func showCollection(collection: Collection)() {
//		Analytics.track(.ChangedCollection(collection: collection))
//		let viewController = CanvasesViewController(account: account, collection: collection)
//		navigationController?.pushViewController(viewController, animated: true)
//	}


	// MARK: - Private

	private func reloadRows() {
		
	}
}
