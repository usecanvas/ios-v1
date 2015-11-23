//
//  ListViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class ListViewController: TableViewController {

	// MARK: - Properties

	var loading = false {
		didSet {
			if !loading {
				refreshControl?.endRefreshing()
			}
		}
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let control = UIRefreshControl()
		control.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
		refreshControl = control
	}


	// MARK: - Actions

	func refresh() {
		// Do nothing
	}
}
