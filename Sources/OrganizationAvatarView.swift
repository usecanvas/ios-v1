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
	
	private let avatarView = AvatarView()

	private let initialsLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.white
		label.textAlignment = .Center
		label.font = Font.sansSerif(weight: .medium, size: .small)
		return label
	}()


	// MARK: - UIView
	
	override func tintColorDidChange() {
		if let organization = organization where organization.isPersonalNotes {
			return
		}
		
		backgroundColor = tintColor
	}
	
	override func layoutSubviews() {
		if initialsLabel.superview != nil {
			initialsLabel.frame = bounds
		}
		
		if avatarView.superview != nil {
			avatarView.frame = bounds
		}
	}


	// MARK: - Private

	private func updateUI() {
		guard let organization = organization else {
			initialsLabel.removeFromSuperview()
			initialsLabel.text = nil
			tintColor = highlighted ? Swatch.white : Swatch.cellDisclosureIndicator
			avatarView.removeFromSuperview()
			avatarView.user = nil
			
			tintColor = highlighted ? Swatch.white : Swatch.cellDisclosureIndicator
			return
		}
		
		if organization.isPersonalNotes, let user = AccountController.sharedController.currentAccount?.user {
			initialsLabel.removeFromSuperview()
			initialsLabel.text = nil
			
			avatarView.user = user
			
			if avatarView.superview == nil {
				layer.cornerRadius = 0
				addSubview(avatarView)
				setNeedsLayout()
			}

			backgroundColor = .clearColor()
			return
		}
		
		avatarView.removeFromSuperview()
		avatarView.user = nil

		let orgColor = organization.color?.uiColor ?? Swatch.brand

		tintColor = highlighted ? Swatch.white : orgColor

		let name = organization.name
		initialsLabel.text = name.substringToIndex(name.startIndex.advancedBy(2))
		initialsLabel.textColor = highlighted ? orgColor : Swatch.white
		
		if initialsLabel.superview == nil {
			layer.cornerRadius = 4
			tintColorDidChange()
			addSubview(initialsLabel)
			setNeedsLayout()
		}
	}
}
