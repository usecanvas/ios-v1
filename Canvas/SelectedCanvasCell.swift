//
//  SelectedCanvasCell.swift
//  Canvas
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class SelectedCanvasCell: CanvasCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		let indicator = UIView()
		indicator.translatesAutoresizingMaskIntoConstraints = false
		indicator.backgroundColor = Color.brand
		indicator.layer.cornerRadius = 2

		contentView.addSubview(indicator)

		NSLayoutConstraint.activateConstraints([
			indicator.widthAnchor.constraintEqualToConstant(4),
			indicator.trailingAnchor.constraintEqualToAnchor(textLabel!.leadingAnchor, constant: -4),
			indicator.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 8),
			indicator.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -8)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
