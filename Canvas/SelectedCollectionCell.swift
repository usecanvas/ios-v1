//
//  SelectedCollectionCell.swift
//  Canvas
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class SelectedCollectionCell: CollectionCell {

	// MARK: - Properties

	let keyboardSelectionView: KeyboardSelectionView = {
		let indicator = KeyboardSelectionView()
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()

	private var keyboardSelectionViewConstraints: [NSLayoutConstraint]?


	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(keyboardSelectionView)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		if let keyboardSelectionViewConstraints = keyboardSelectionViewConstraints {
			NSLayoutConstraint.deactivateConstraints(keyboardSelectionViewConstraints)
		}

		var constraints: [NSLayoutConstraint] = [
			keyboardSelectionView.widthAnchor.constraintEqualToConstant(4),
			keyboardSelectionView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 8),
			keyboardSelectionView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -8)
		]

		if traitCollection.horizontalSizeClass == .Compact {
			constraints.append(keyboardSelectionView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor))
		} else {
			constraints.append(keyboardSelectionView.trailingAnchor.constraintEqualToAnchor(textLabel!.leadingAnchor, constant: -8))
		}

		keyboardSelectionViewConstraints = constraints
		NSLayoutConstraint.activateConstraints(constraints)
	}
}
