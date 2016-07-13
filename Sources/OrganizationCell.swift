//
//  OrganizationCell.swift
//  Canvas
//
//  Created by Sam Soffes on 1/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore
import CanvasKit
import CanvasText

final class OrganizationCell: UITableViewCell, CellType {

	// MARK: - Properties

	let avatarView: OrganizationAvatarView = {
		let view = OrganizationAvatarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Swatch.white
		label.textColor = Swatch.black
		label.highlightedTextColor = Swatch.white
		label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
		return label
	}()

	let disclosureIndicatorView = UIImageView(image: UIImage(named: "ChevronRightSmall"))


	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

		let view = UIView()
		view.backgroundColor = tintColor
		selectedBackgroundView = view

		accessoryView = disclosureIndicatorView

		setupViews()
		setupConstraints()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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


	// MARK: - Configuration

	func setupViews() {
		contentView.addSubview(avatarView)
		contentView.addSubview(titleLabel)
	}

	func setupConstraints() {
		NSLayoutConstraint.activateConstraints([
			contentView.heightAnchor.constraintGreaterThanOrEqualToConstant(56),

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

		let organization = row.context?["organization"] as? Organization
		avatarView.organization = organization
		selectedBackgroundView?.backgroundColor = organization?.color?.uiColor ?? Swatch.brand
	}


	// MARK: - Private

	private func updateHighlighted() {
		avatarView.highlighted = highlighted || selected
		disclosureIndicatorView.tintColor = highlighted || selected ? Swatch.white : Swatch.cellDisclosureIndicator
	}
	
	@objc private func updateFont() {
		titleLabel.font = TextStyle.body.font(weight: .medium)
	}
}
