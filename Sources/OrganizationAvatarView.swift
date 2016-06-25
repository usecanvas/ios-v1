//
//  OrganizationAvatarView.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit

final class OrganizationAvatarView: UIView {

	// MARK: - Properties

	var highlighted = false {
		didSet {
			updateUI()
		}
	}

	var organization: Organization? {
		didSet {
			updateUI()
		}
	}

	private let initialsLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Swatch.white
		label.textAlignment = .Center
		label.font = Font.sansSerif(weight: .medium, size: .small)
		return label
	}()


	// MARK: - Initializers

	init() {
		super.init(frame: .zero)

		layer.cornerRadius = 4

		addSubview(initialsLabel)

		NSLayoutConstraint.activateConstraints([
			initialsLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			initialsLabel.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			initialsLabel.topAnchor.constraintEqualToAnchor(topAnchor),
			initialsLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	
	override func tintColorDidChange() {
		backgroundColor = tintColor
	}


	// MARK: - Private

	private func updateUI() {
		guard let organization = organization else {
			initialsLabel.text = nil
			tintColor = highlighted ? Swatch.white : Swatch.cellDisclosureIndicator
			return
		}

		let orgColor = organization.color?.uiColor ?? Swatch.brand

		tintColor = highlighted ? Swatch.white : orgColor

		let name = organization.name
		initialsLabel.text = name.substringToIndex(name.startIndex.advancedBy(2))
		initialsLabel.textColor = highlighted ? orgColor : Swatch.white
	}
}
