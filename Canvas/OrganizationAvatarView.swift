//
//  OrganizationAvatarView.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
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
		label.textColor = .whiteColor()
		label.textAlignment = .Center
		label.font = Font.sansSerif(weight: .Bold, size: .Small)
		return label
	}()


	// MARK: - Initializers

	init() {
		super.init(frame: .zero)

		layer.cornerRadius = 4
		layer.masksToBounds = true

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


	// MARK: - Private

	private func updateUI() {
		guard let organization = organization else {
			initialsLabel.text = nil
			backgroundColor = highlighted ? .whiteColor() : Color.gray
			return
		}

		backgroundColor = highlighted ? .whiteColor() : organization.color?.UIColor ?? Color.gray

		let name = organization.name
		initialsLabel.text = name.substringToIndex(name.startIndex.advancedBy(2))
		initialsLabel.textColor = highlighted ? organization.color?.UIColor ?? Color.brand : .whiteColor()
	}
}
