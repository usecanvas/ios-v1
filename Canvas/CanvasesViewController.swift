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
}
