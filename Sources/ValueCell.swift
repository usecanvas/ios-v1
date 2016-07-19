//
//  ValueCell.swift
//  Canvas
//
//  Created by Sam Soffes on 7/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore

final class ValueCell: UITableViewCell, CellType {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
		textLabel?.textColor = Swatch.black
		detailTextLabel?.textColor = Swatch.darkGray
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(row row: Row) {
		textLabel?.text = row.text
		detailTextLabel?.text = row.detailText
		imageView?.image = row.image

		switch row.accessory {
		case .DisclosureIndicator:
			let view = UIImageView(image: UIImage(named: "ChevronRightSmall"))
			view.tintColor = Swatch.lightGray
			accessoryView = view
		default:
			accessoryType = row.accessory.type
			accessoryView = row.accessory.view
		}
	}
}
