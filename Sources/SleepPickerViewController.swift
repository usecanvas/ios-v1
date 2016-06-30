//
//  SleepPickerViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static

final class SleepPickerViewController: TableViewController {

	// MARK: - Initializers

	convenience init() {
		self.init(style: .Grouped)
		title = "Prevent Display Sleep"
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let preference = SleepPrevention.currentPreference
		let rows: [Row] = SleepPrevention.all.map { option in
			let accessory: Row.Accessory = option == preference ? .Checkmark : .None
			return Row(text: option.description, selection: { [weak self] in
				self?.select(option)
			}, accessory: accessory)
		}

		dataSource.sections = [
			Section(rows: rows)
		]
	}


	// MARK: - Private

	private func select(preference: SleepPrevention) {
		SleepPrevention.select(preference)
		navigationController?.popViewControllerAnimated(true)
	}
}
