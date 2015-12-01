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

class CanvasesViewController: ListViewController, Accountable {

	// MARK: - Properties

	var account: Account
	let collection: Collection

	var canvases = [Canvas]() {
		didSet {
			reloadRows()
		}
	}

	private var selectedCanvas: Canvas? {
		didSet {
			reloadRows()
		}
	}


	// MARK: - Initializers

	init(account: Account, collection: Collection) {
		self.account = account
		self.collection = collection
		super.init(nibName: nil, bundle: nil)
		title = collection.name.capitalizedString
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		return [
			UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [], action: "goBack:", discoverabilityTitle: "Back to Collections"),
			UIKeyCommand(input: "w", modifierFlags: [.Command], action: "goBack:"),
			UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: "selectPreviousCanvas:", discoverabilityTitle: "Previous Canvas"),
			UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: "selectNextCanvas:", discoverabilityTitle: "Next Canvas"),
			UIKeyCommand(input: "\r", modifierFlags: [], action: "openSelectedCanvas:", discoverabilityTitle: "Open Canvas"),
			UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: "openSelectedCanvas:"),
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "clearSelectedCanvas:", discoverabilityTitle: "Clear Selection"),
			UIKeyCommand(input: "e", modifierFlags: [.Command], action: "archiveSelectedCanvas:", discoverabilityTitle: "Archive Selected Canvas"),
			UIKeyCommand(input: "\u{8}", modifierFlags: [.Command], action: "deleteSelectedCanvas:", discoverabilityTitle: "Delete Selected Canvas")
		]
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rowHeight = 72
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		refresh()
	}


	// MARK: - Actions

	func goBack(sender: AnyObject?) {
		navigationController?.popViewControllerAnimated(true)
	}

	func selectPreviousCanvas(sender: AnyObject?) {
		guard let selectedCanvas = selectedCanvas, index = canvases.indexOf({ $0.ID == selectedCanvas.ID }) else {
			self.selectedCanvas = canvases.first
			return
		}

		if index == 0 {
			return
		}

		self.selectedCanvas = canvases[index.predecessor()]
	}

	func selectNextCanvas(sender: AnyObject?) {
		guard let selectedCanvas = selectedCanvas, index = canvases.indexOf({ $0.ID == selectedCanvas.ID }) else {
			self.selectedCanvas = canvases.first
			return
		}

		if index == canvases.count - 1 {
			return
		}

		self.selectedCanvas = canvases[index.successor()]

	}

	func openSelectedCanvas(sender: AnyObject?) {
		guard let canvas = selectedCanvas ?? canvases.first else { return }
		showCanvas(canvas)()
	}

	func clearSelectedCanvas(sender: AnyObject?) {
		selectedCanvas = nil
	}

	func deleteSelectedCanvas(sender: AnyObject?) {
		guard let canvas = selectedCanvas else { return }
		deleteCanvas(canvas)()
	}

	func archiveSelectedCanvas(sender: AnyObject?) {
		guard let canvas = selectedCanvas else { return }
		archiveCanvas(canvas)()
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
					self?.canvases = canvases
				}
			case .Failure(let message):
				print("Failed to get canvases: \(message)")
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
				}
			}
		}
	}

	private func showCanvas(canvas: Canvas)() {
		Analytics.track(.OpenedCanvas)
		let viewController = EditorViewController(account: account, canvas: canvas)
		navigationController?.pushViewController(viewController, animated: true)
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


	// MARK: - Private

	private func reloadRows() {
		let rows = canvases.map {
			Row(
				text: $0.displayTitle,
				detailText: $0.summary,
				accessory: .DisclosureIndicator,
				selection: showCanvas($0),
				cellClass: canvasCellClass($0),
				editActions: [
					Row.EditAction(title: "Archive", style: .Destructive, backgroundColor: Color.darkGray, backgroundEffect: nil, selection: deleteCanvas($0)),
					Row.EditAction(title: "Delete", style: .Destructive, backgroundColor: Color.destructive, backgroundEffect: nil, selection: deleteCanvas($0))
				]
			)
		}

		dataSource.sections = [Section(rows: rows)]
	}

	private func canvasCellClass(canvas: Canvas) -> CellType.Type {
		let selected = selectedCanvas.flatMap { $0.ID == canvas.ID } ?? false
		return selected ? SelectedCanvasCell.self : CanvasCell.self
	}
}
