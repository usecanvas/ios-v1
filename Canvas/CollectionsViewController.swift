//
//  CollectionsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit

class CollectionsViewController: ListViewController<Collection>, Accountable {

	// MARK: - Properties

	var account: Account

	private var selectedCollection: Collection? {
		didSet {
			reloadRows()
		}
	}


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		super.init(nibName: nil, bundle: nil)
		title = "Collections"
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}



	// MARK: - UIResponder

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []
		commands += [
			UIKeyCommand(input: "Q", modifierFlags: [.Shift, .Command], action: "logOut:", discoverabilityTitle: "Log Out")
		]
		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Color.lightGray
		tableView.rowHeight = 64
		tableView.separatorColor = Color.gray

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: "logOut:")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		refresh()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		guard let navigationBar = navigationController?.navigationBar else { return }

		navigationBar.barTintColor = Color.darkGray
		navigationBar.barStyle = .Black
		navigationBar.tintColor = Color.white.colorWithAlphaComponent(0.7)
		navigationBar.translucent = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		guard let navigationBar = navigationController?.navigationBar else { return }

		navigationBar.barTintColor = Color.brand
		navigationBar.translucent = false
	}


	// MARK: - Actions

	func logOut(sender: AnyObject?) {
		Analytics.track(.LoggedIn)
		AccountController.sharedController.currentAccount = nil
	}

	override func refresh() {
		if loading {
			return
		}

		loading = true
		
		APIClient(accessToken: account.accessToken, baseURL: baseURL).listCollections { [weak self] result in
			switch result {
			case .Success(let collections):
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
					self?.collections = collections
				}
			case .Failure(let message):
				print("Failed to get collections: \(message)")
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
				}
			}
		}
	}


	// MARK: - Private

	private func reloadRows() {
		let rows = collections.map {
			Row(
				text: $0.name,
				accessory: .DisclosureIndicator,
				selection: showCollection($0),
				cellClass: collectionCellClass($0)
			)
		}

		dataSource.sections = [Section(rows: rows)]
	}

	private func collectionCellClass(collection: Collection) -> CellType.Type {
		let selected = selectedCollection.flatMap { $0.ID == collection.ID } ?? false
		return selected ? SelectedCollectionCell.self : CollectionCell.self
	}

	// TODO: Guard against pushing multiple at the same time
	private func showCollection(collection: Collection)() {
		Analytics.track(.ChangedCollection(collection: collection))
		let viewController = CanvasesViewController(account: account, collection: collection)
		navigationController?.pushViewController(viewController, animated: true)
	}
}
