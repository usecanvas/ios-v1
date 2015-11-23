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
			let rows = canvases.map { canvas in
				Row(text: canvas.title ?? "Untitled", accessory: .DisclosureIndicator, selection: showCanvas(canvas), cellClass: CanvasCell.self, editActions: [
					Row.EditAction(title: "Delete", style: .Destructive, backgroundColor: nil, backgroundEffect: nil, selection: deleteCanvas(canvas))
				])
			}
			dataSource.sections = [Section(rows: rows)]
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


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rowHeight = 66
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		refresh()
	}


	// MARK: - Actions

	override func refresh() {
		if loading {
			return
		}

		loading = true

		APIClient(accessToken: account.accessToken).listCanvases(collection) { [weak self] result in
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
		let viewController = EditorViewController(account: account, canvas: canvas)
		navigationController?.pushViewController(viewController, animated: true)
	}

	private func deleteCanvas(canvas: Canvas)() {
		let title = canvas.title ?? "Untitled"
		let actionSheet = UIAlertController(title: "Are you sure you want to delete “\(title)”?", message: nil, preferredStyle: .ActionSheet)

		actionSheet.addAction(UIAlertAction(title: "Delete", style: .Destructive) { [weak self] _ in
			guard let accessToken = self?.account.accessToken else { return }
			APIClient(accessToken: accessToken).destroyCanvas(canvas) { _ in
				dispatch_async(dispatch_get_main_queue()) {
					self?.refresh()
				}
			}
		})

		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		
		presentViewController(actionSheet, animated: true, completion: nil)
	}
}
