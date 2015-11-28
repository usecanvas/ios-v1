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
		label.textColor = Color.black
		label.highlightedTextColor = Color.white
		label.font = Font.sansSerif(weight: .Bold)
		return label
	}()

	let descriptionLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Color.darkGray
		label.highlightedTextColor = Color.white
		label.font = Font.sansSerif(size: .Subtitle)
		return label
	}()

	let timeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
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

		textLabel?.font = Font.sansSerif()
		textLabel?.highlightedTextColor = Color.white

//		contentView.addSubview(titleLabel)
//		contentView.addSubview(descriptionLabel)
//		contentView.addSubview(timeLabel)
//
//		let verticalSpacing: CGFloat = 2
//
//		NSLayoutConstraint.activateConstraints([
//			titleLabel.bottomAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: -verticalSpacing),
//			NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0),
//			titleLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(timeLabel.leadingAnchor),
//
//			descriptionLabel.topAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: verticalSpacing),
//			descriptionLabel.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor),
//			descriptionLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor),
//
//			NSLayoutConstraint(item: timeLabel, attribute: .Baseline, relatedBy: .Equal, toItem: titleLabel, attribute: .Baseline, multiplier: 1, constant: 0),
//			timeLabel.trailingAnchor.constraintEqualToAnchor(descriptionLabel.trailingAnchor),
//			timeLabel.widthAnchor.constraintLessThanOrEqualToConstant(100)
//		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


extension CanvasCell: CellType {
	func configure(row row: Row) {
//		titleLabel.text = row.text
//		descriptionLabel.text = "This is a lovely canvas about cool things that are super important. No really. Really important. Okay, this is probably long enough."
//		timeLabel.text = "1m"
		textLabel?.text = row.text
		accessoryType = row.accessory.type
	}
}
