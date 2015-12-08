//
//  CanvasesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit
import AlgoliaSearch

class CanvasesViewController: PlainCanvasesViewController {

	// MARK: - Properties

	let collection: Collection

	private let searchController: SearchController

	private let searchViewController: UISearchController


	// MARK: - Initializers

	init(account: Account, collection: Collection) {
		self.collection = collection
		searchController = SearchController(account: account, collection: collection)
		searchViewController = UISearchController(searchResultsController: PlainCanvasesViewController(account: account))

		super.init(account: account)

		title = collection.name.capitalizedString

		searchViewController.searchBar.placeholder = "Search in \(collection.name.capitalizedString)"
		searchViewController.searchResultsUpdater = searchController

		searchController.callback = { [weak self] canvases in
			guard let viewController = self?.searchViewController.searchResultsController as? PlainCanvasesViewController else { return }
			viewController.arrangedModels = canvases.map { $0 as Model }
		}
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []

		commands += [
			UIKeyCommand(input: "/", modifierFlags: [], action: "search:", discoverabilityTitle: "Search"),
			UIKeyCommand(input: "e", modifierFlags: [.Command], action: "archiveSelectedCanvas:", discoverabilityTitle: "Archive Selected Canvas"),
			UIKeyCommand(input: "\u{8}", modifierFlags: [.Command], action: "deleteSelectedCanvas:", discoverabilityTitle: "Delete Selected Canvas")
		]

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		definesPresentationContext = true
		extendedLayoutIncludesOpaqueBars = true

		searchViewController.hidesNavigationBarDuringPresentation = true

		tableView.tableHeaderView = searchViewController.searchBar
	}


	// MARK: - ModelsViewController

	override var canRefresh: Bool {
		return true
	}

	override func refresh() {
		if loading {
			return
		}

		loading = true

		APIClient(accessToken: account.accessToken, baseURL: baseURL).listCanvases(collection) { [weak self] result in
			switch result {
			case .Success(let canvases):
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
					self?.arrangedModels = canvases.map { $0 as Model }
				}
			case .Failure(let message):
				print("Failed to get canvases: \(message)")
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
				}
			}
		}
	}

	override func rowForModel(model: Model, isSelected: Bool) -> Row? {
		guard let canvas = model as? Canvas, var row = super.rowForModel(model, isSelected: isSelected) else { return nil }

		row.editActions = [
			Row.EditAction(title: "Archive", style: .Destructive, backgroundColor: Color.darkGray, backgroundEffect: nil, selection: deleteCanvas(canvas)),
			Row.EditAction(title: "Delete", style: .Destructive, backgroundColor: Color.destructive, backgroundEffect: nil, selection: deleteCanvas(canvas))
		]

		return row
	}


	// MARK: - Actions

	func search(sender: AnyObject?) {
		searchViewController.searchBar.becomeFirstResponder()
	}

	func deleteSelectedCanvas(sender: AnyObject?) {
		guard let canvas = selectedModel as? Canvas else { return }
		deleteCanvas(canvas)()
	}

	func archiveSelectedCanvas(sender: AnyObject?) {
		guard let canvas = selectedModel as? Canvas else { return }
		archiveCanvas(canvas)()
	}

	private func deleteCanvas(canvas: Canvas)() {
		let style: UIAlertControllerStyle = traitCollection.userInterfaceIdiom == .Pad ? .Alert : .ActionSheet
		let actionSheet = AlertController(title: "Are you sure you want to delete “\(canvas.displayTitle)”?", message: nil, preferredStyle: style)

		let delete = { [weak self] in
			guard let accessToken = self?.account.accessToken else { return }
			APIClient(accessToken: accessToken, baseURL: baseURL).destroyCanvas(canvas: canvas) { _ in
				dispatch_async(dispatch_get_main_queue()) {
					self?.refresh()
				}
			}
		}

		actionSheet.addAction(UIAlertAction(title: "Delete", style: .Destructive) { _ in delete() })
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		actionSheet.primaryAction = delete

		presentViewController(actionSheet, animated: true, completion: nil)
	}

	private func archiveCanvas(canvas: Canvas)() {
		let style: UIAlertControllerStyle = traitCollection.userInterfaceIdiom == .Pad ? .Alert : .ActionSheet
		let actionSheet = AlertController(title: "Are you sure you want to archive “\(canvas.displayTitle)”?", message: nil, preferredStyle: style)

		let archive = { [weak self] in
			guard let accessToken = self?.account.accessToken else { return }
			APIClient(accessToken: accessToken, baseURL: baseURL).archiveCanvas(canvas: canvas) { _ in
				dispatch_async(dispatch_get_main_queue()) {
					self?.refresh()
				}
			}
		}

		actionSheet.addAction(UIAlertAction(title: "Archive", style: .Destructive) { _ in archive() })
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		actionSheet.primaryAction = archive

		presentViewController(actionSheet, animated: true, completion: nil)
	}
}
