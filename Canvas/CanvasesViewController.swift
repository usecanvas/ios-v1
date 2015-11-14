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

class CanvasesViewController: TableViewController, Accountable {

	// MARK: - Properties

	var account: Account
	let collection: Collection

	var canvases = [Canvas]() {
		didSet {
			let rows = canvases.map {
				Row(text: $0.shortID, accessory: .DisclosureIndicator, selection: showCanvas($0))
			}

			dataSource.sections = [Section(rows: rows)]
		}
	}


	// MARK: - Initializers

	init(account: Account, collection: Collection) {
		self.account = account
		self.collection = collection
		super.init(nibName: nil, bundle: nil)
		title = collection.name
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}


	// MARK: - Private

	private func refresh() {
		APIClient(accessToken: account.accessToken).listCanvases(collection) { [weak self] result in
			switch result {
			case .Success(let canvases):
				dispatch_async(dispatch_get_main_queue()) {
					self?.canvases = canvases
				}
			case .Failure(let message):
				print("Failed to get canvases: \(message)")
			}
		}
	}

	private func showCanvas(canvas: Canvas)() {
		let viewController = EditorViewController(account: account, canvas: canvas)
		navigationController?.pushViewController(viewController, animated: true)
	}
}
