//
//  OrganizationCell.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit

class OrganizationCell: UITableViewCell {

	// MARK: - Properties

	let avatarView: OrganizationAvatarView = {
		let view = OrganizationAvatarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.black
		label.highlightedTextColor = Color.white
		label.font = Font.sansSerif(weight: .Bold)
		label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
		return label
	}()

	let membersLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.darkGray
		label.highlightedTextColor = Color.white
		return label
	}()


	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

		let view = UIView()
		view.backgroundColor = Color.brand
		selectedBackgroundView = view

		contentView.addSubview(avatarView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(membersLabel)

		let verticalSpacing: CGFloat = 2

		NSLayoutConstraint.activateConstraints([
			NSLayoutConstraint(item: avatarView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0),
			avatarView.widthAnchor.constraintEqualToConstant(32),
			avatarView.heightAnchor.constraintEqualToConstant(32),
			avatarView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor),

			titleLabel.bottomAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: -verticalSpacing),
			titleLabel.leadingAnchor.constraintEqualToAnchor(avatarView.trailingAnchor, constant: 8),
			NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: contentView, attribute: .TrailingMargin, multiplier: 1, constant: 0),

			membersLabel.topAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: verticalSpacing),
			membersLabel.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor),
			membersLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


extension OrganizationCell: CellType {
	func configure(row row: Row) {
		titleLabel.text = row.text
		membersLabel.text = row.detailText
		accessoryType = row.accessory.type
		avatarView.organization = row.context?["organization"] as? Organization
	}
}
