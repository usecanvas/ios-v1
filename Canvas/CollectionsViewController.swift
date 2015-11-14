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

class CollectionsViewController: TableViewController, Accountable {

	// MARK: - Properties

	var account: Account

	var collections = [Collection]() {
		didSet {
			let rows = collections.map {
				Row(text: $0.name, accessory: .DisclosureIndicator, selection: showCollection($0))
			}

			dataSource.sections = [Section(rows: rows)]
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


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: "signOut:")

		refresh()
	}


	// MARK: - Actions

	@objc private func signOut(sender: AnyObject?) {
		AccountController.sharedController.currentAccount = nil
	}


	// MARK: - Private

	private func refresh() {
		APIClient(accessToken: account.accessToken).listCollections { [weak self] result in
			switch result {
			case .Success(let collections):
				dispatch_async(dispatch_get_main_queue()) {
					self?.collections = collections
				}
			case .Failure(let message):
				print("Failed to get collections: \(message)")
			}
		}
	}

	private func showCollection(collection: Collection)() {
		let viewController = CanvasesViewController(account: account, collection: collection)
		navigationController?.pushViewController(viewController, animated: true)
	}
}
