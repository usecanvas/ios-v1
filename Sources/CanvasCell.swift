//
//  CanvasCell.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore
import CanvasKit

final class CanvasCell: UITableViewCell {

	// MARK: - Properties

	let iconView: CanvasIconView = {
		let view = CanvasIconView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = UIColor(red: 0.478, green: 0.475, blue: 0.482, alpha: 1)
		view.highlightedTintColor = Swatch.white
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Swatch.white
		label.textColor = Swatch.black
		label.highlightedTextColor = Swatch.white
		label.font = Font.sansSerif(weight: .bold)
		label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
		return label
	}()

	let summaryLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Swatch.white
		label.textColor = Swatch.black
		label.highlightedTextColor = Swatch.white
		return label
	}()

	let timeLabel: TickingLabel = {
		let label = TickingLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Swatch.white
		label.textColor = Swatch.gray
		label.highlightedTextColor = Swatch.white
		label.font = Font.sansSerif(size: .small).fontWithMonospaceNumbers
		label.textAlignment = .Right
		return label
	}()

	let disclosureIndicatorView = UIImageView(image: UIImage(named: "ChevronRightSmall"))

	private var canvas: Canvas? {
		didSet {
			updateHighlighted()

			guard let canvas = canvas else {
				timeLabel.text = nil
				return
			}

			iconView.canvas = canvas

			if canvas.archivedAt == nil {
				titleLabel.textColor = Swatch.black
				summaryLabel.textColor = Swatch.black
			} else {
				titleLabel.textColor = Swatch.gray
				summaryLabel.textColor = Swatch.gray
			}

			timeLabel.date = canvas.updatedAt
		}
	}
	

	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

		let view = UIView()
		view.backgroundColor = tintColor
		selectedBackgroundView = view

		accessoryView = disclosureIndicatorView

		contentView.addSubview(iconView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(summaryLabel)
		contentView.addSubview(timeLabel)

		let verticalSpacing: CGFloat = 2

		NSLayoutConstraint.activateConstraints([
			NSLayoutConstraint(item: iconView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0),
			iconView.widthAnchor.constraintEqualToConstant(28),
			iconView.heightAnchor.constraintEqualToConstant(28),
			iconView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor),

			titleLabel.bottomAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: -verticalSpacing),
			titleLabel.leadingAnchor.constraintEqualToAnchor(iconView.trailingAnchor, constant: 8),
			titleLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(timeLabel.leadingAnchor),

			summaryLabel.topAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: verticalSpacing),
			summaryLabel.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor),
			summaryLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -8),

			NSLayoutConstraint(item: timeLabel, attribute: .Baseline, relatedBy: .Equal, toItem: titleLabel, attribute: .Baseline, multiplier: 1, constant: 0),
			timeLabel.trailingAnchor.constraintEqualToAnchor(summaryLabel.trailingAnchor),
			timeLabel.widthAnchor.constraintLessThanOrEqualToConstant(100)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		selectedBackgroundView?.backgroundColor = tintColor
	}
	

	// MARK: - UITableViewCell

	override func setHighlighted(highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		updateHighlighted()
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		updateHighlighted()
	}


	// MARK: - Private

	private func updateHighlighted() {
		iconView.highlighted = highlighted || selected

		if highlighted || selected {
			disclosureIndicatorView.tintColor = Swatch.white
		} else {
			disclosureIndicatorView.tintColor = canvas?.archivedAt == nil ? Swatch.cellDisclosureIndicator : Swatch.lightGray
		}
	}
}


extension CanvasCell: CellType {
	func configure(row row: Row) {
		titleLabel.text = row.text

		if let summary = row.detailText where summary.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
			summaryLabel.text = summary
			summaryLabel.font = Font.sansSerif(size: .subtitle)
		} else {
			summaryLabel.text = "No Content"
			summaryLabel.font = Font.sansSerif(size: .subtitle, style: .italic)
		}

		canvas = row.context?["canvas"] as? Canvas
	}
}
