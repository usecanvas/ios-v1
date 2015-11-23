//
//  TableViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static

class TableViewController: UITableViewController {

	// MARK: - Properties

	/// Table view data source.
	var dataSource = DataSource() {
		willSet {
			dataSource.tableView = nil
		}

		didSet {
			dataSource.tableView = tableView
		}
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource.tableView = tableView
	}
}
