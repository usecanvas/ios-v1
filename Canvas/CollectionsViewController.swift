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

class CollectionsViewController: ListViewController, Accountable {

	// MARK: - Properties

	var account: Account

	var collections = [Collection]() {
		didSet {
			let rows = collections.map {
				Row(text: $0.name, accessory: .DisclosureIndicator, selection: showCollection($0), cellClass: CollectionCell.self)
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

		view.backgroundColor = Color.lightGray
		tableView.rowHeight = 64
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
		tableView.separatorColor = Color.gray

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: "signOut:")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		refresh()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.barTintColor = Color.darkGray
		navigationController?.navigationBar.barStyle = .Black
		navigationController?.navigationBar.tintColor = Color.white.colorWithAlphaComponent(0.5)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.navigationBar.barTintColor = Color.white
		navigationController?.navigationBar.barStyle = .Default
		navigationController?.navigationBar.tintColor = Color.brand
	}


	// MARK: - Actions

	@objc private func signOut(sender: AnyObject?) {
		AccountController.sharedController.currentAccount = nil
	}

	override func refresh() {
		if loading {
			return
		}

		loading = true
		
		APIClient(accessToken: account.accessToken).listCollections { [weak self] result in
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

	private func showCollection(collection: Collection)() {
		let viewController = CanvasesViewController(account: account, collection: collection)
		navigationController?.pushViewController(viewController, animated: true)
	}
}
