//
//  CanvasCell.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static

class CanvasCell: UITableViewCell {

	// MARK: - Properties

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.black
		label.highlightedTextColor = Color.white
		label.font = Font.sansSerif(weight: .Bold)
		return label
	}()

	let summaryLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.darkGray
		label.highlightedTextColor = Color.white
		return label
	}()

	let timeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.gray
		label.highlightedTextColor = Color.white
		label.font = Font.sansSerif(size: .Small)
		label.textAlignment = .Right
		return label
	}()


	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

		let view = UIView()
		view.backgroundColor = Color.brand
		selectedBackgroundView = view

		contentView.addSubview(titleLabel)
		contentView.addSubview(summaryLabel)
		contentView.addSubview(timeLabel)

		let verticalSpacing: CGFloat = 2

		NSLayoutConstraint.activateConstraints([
			titleLabel.bottomAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: -verticalSpacing),
			NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0),
			titleLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(timeLabel.leadingAnchor),

			summaryLabel.topAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: verticalSpacing),
			summaryLabel.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor),
			summaryLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor),

			NSLayoutConstraint(item: timeLabel, attribute: .Baseline, relatedBy: .Equal, toItem: titleLabel, attribute: .Baseline, multiplier: 1, constant: 0),
			timeLabel.trailingAnchor.constraintEqualToAnchor(summaryLabel.trailingAnchor),
			timeLabel.widthAnchor.constraintLessThanOrEqualToConstant(100)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


extension CanvasCell: CellType {
	func configure(row row: Row) {
		titleLabel.text = row.text

		if let summary = row.detailText where !summary.isEmpty {
			summaryLabel.text = summary
			summaryLabel.font = Font.sansSerif(size: .Subtitle)
		} else {
			summaryLabel.text = "No Content"
			summaryLabel.font = Font.sansSerif(size: .Subtitle, style: .Italic)
		}

//		timeLabel.text = "1m"
		accessoryType = row.accessory.type
	}
}
