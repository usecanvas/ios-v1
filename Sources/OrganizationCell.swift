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

class OrganizationCell: PersonalOrganizationCell {

	// MARK: - Properties

	let membersLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.darkGray
		label.highlightedTextColor = Color.white
		return label
	}()


	// MARK: - PersonalOrganizationCell

	override func setupViews() {
		super.setupViews()
		contentView.addSubview(membersLabel)
	}

	override func setupConstraints() {
		let verticalSpacing: CGFloat = 2

		NSLayoutConstraint.activateConstraints([
			contentView.heightAnchor.constraintGreaterThanOrEqualToConstant(66),

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

	override func configure(row row: Row) {
		super.configure(row: row)
		membersLabel.text = row.detailText
	}
}
