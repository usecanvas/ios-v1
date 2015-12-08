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


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		super.init()
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


	// MARK: - ListViewController

	override var itemTypeName: String {
		return "Collection"
	}

	override func rowForItem(item: Collection, isSelected: Bool) -> Row {
		return Row(
			text: item.name,
			accessory: .DisclosureIndicator,
			selection: { [weak self] in self?.selectItem(item) },
			cellClass: isSelected ? SelectedCollectionCell.self : CollectionCell.self
		)
	}

	override func selectItem(item: Collection) {
		// TODO: Guard against pushing multiple at the same time
		Analytics.track(.ChangedCollection(collection: item))
//		let viewController = CanvasesViewController(account: account, collection: item)
		navigationController?.pushViewController(UIViewController(), animated: true)
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
					self?.arrangedItems = collections
				}
			case .Failure(let message):
				print("Failed to get collections: \(message)")
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
				}
			}
		}
	}


	// MARK: - Actions

	func logOut(sender: AnyObject?) {
		Analytics.track(.LoggedIn)
		AccountController.sharedController.currentAccount = nil
	}
}
