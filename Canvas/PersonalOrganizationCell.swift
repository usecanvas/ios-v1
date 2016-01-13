//
//  PersonalOrganizationCell.swift
//  Canvas
//
//  Created by Sam Soffes on 1/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit

class PersonalOrganizationCell: UITableViewCell, CellType {

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


	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

		let view = UIView()
		view.backgroundColor = Color.brand
		selectedBackgroundView = view

		setupViews()
		setupConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Configuration

	func setupViews() {
		contentView.addSubview(avatarView)
		contentView.addSubview(titleLabel)
	}

	func setupConstraints() {
		NSLayoutConstraint.activateConstraints([
			contentView.heightAnchor.constraintEqualToConstant(56),

			NSLayoutConstraint(item: avatarView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0),
			avatarView.widthAnchor.constraintEqualToConstant(32),
			avatarView.heightAnchor.constraintEqualToConstant(32),
			avatarView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor),

			titleLabel.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor),
			titleLabel.leadingAnchor.constraintEqualToAnchor(avatarView.trailingAnchor, constant: 8),
			NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: contentView, attribute: .TrailingMargin, multiplier: 1, constant: 0),
		])
	}


	// MARK: - CellType

	func configure(row row: Row) {
		titleLabel.text = row.text
		accessoryType = row.accessory.type
		avatarView.organization = row.context?["organization"] as? Organization
	}
}
