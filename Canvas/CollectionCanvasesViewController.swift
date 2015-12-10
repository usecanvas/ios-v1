//
//  CollectionCanvasesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit
import AlgoliaSearch

class CollectionCanvasesViewController: CanvasesViewController {

	// MARK: - Properties

	let collection: Collection

	private let searchController: SearchController

	private let searchViewController: UISearchController


	// MARK: - Initializers

	init(account: Account, collection: Collection) {
		self.collection = collection
		searchController = SearchController(account: account, collection: collection)

		let results = CanvasesResultsViewController(account: account)
		searchViewController = UISearchController(searchResultsController: results)

		super.init(account: account)

		title = collection.name.capitalizedString

		results.delegate = self

		searchViewController.searchBar.placeholder = "Search in \(collection.name.capitalizedString)"
		searchViewController.searchResultsUpdater = searchController

		searchController.callback = { [weak self] canvases in
			guard let viewController = self?.searchViewController.searchResultsController as? CanvasesViewController else { return }
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
			UIKeyCommand(input: "/", modifierFlags: [], action: "search", discoverabilityTitle: "Search"),
			UIKeyCommand(input: "n", modifierFlags: [.Command], action: "newCanvas", discoverabilityTitle: "New Canvas"),
			UIKeyCommand(input: "e", modifierFlags: [.Command], action: "archiveSelectedCanvas", discoverabilityTitle: "Archive Selected Canvas"),
			UIKeyCommand(input: "\u{8}", modifierFlags: [.Command], action: "deleteSelectedCanvas", discoverabilityTitle: "Delete Selected Canvas")
		]

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// Search setup
		definesPresentationContext = true
		extendedLayoutIncludesOpaqueBars = true
		searchViewController.hidesNavigationBarDuringPresentation = true
		tableView.tableHeaderView = searchViewController.searchBar

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newCanvas")
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

	func newCanvas() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		// TODO: Avoid sending canvas-native here once the API is fixed
		APIClient(accessToken: account.accessToken, baseURL: baseURL).createCanvas(collection: collection, body: "⧙doc-heading⧘\n") { [weak self] result in
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false

				switch result {
				case .Success(let canvas):
					self?.selectModel(canvas)
				case .Failure(let message):
					print("Failed to create canvas: \(message)")
				}
			}
		}
	}

	func search() {
		searchViewController.searchBar.becomeFirstResponder()
	}

	func deleteSelectedCanvas() {
		guard let canvas = selectedModel as? Canvas else { return }
		deleteCanvas(canvas)()
	}

	func archiveSelectedCanvas() {
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


extension CollectionCanvasesViewController: CanvasesResultsViewControllerDelegate {
	func canvasesResultsViewController(viewController: CanvasesResultsViewController, didSelectCanvas canvas: Canvas) {
		selectModel(canvas)
	}
}