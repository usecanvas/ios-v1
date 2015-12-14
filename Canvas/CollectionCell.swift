//
//  OrganizationCell.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static

class OrganizationCell: UITableViewCell, CellType {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		backgroundColor = Color.lightGray
		textLabel?.textColor = Color.darkGray
		textLabel?.highlightedTextColor = Color.white
		textLabel?.font = Font.sansSerif()

		let view = UIView()
		view.backgroundColor = Color.brand
		selectedBackgroundView = view
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	func configure(row row: Row) {
		textLabel?.text = row.text?.capitalizedString
		accessoryType = row.accessory.type
	}
}
