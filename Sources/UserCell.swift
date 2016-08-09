//
//  UserCell.swift
//  Canvas
//
//  Created by Sam Soffes on 8/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import Static

final class UserCell: UITableViewCell {

	// MARK: - Properties

	private let avatarView: AvatarView = {
		let view = AvatarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let usernameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Swatch.black
		return label
	}()


	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		contentView.addSubview(avatarView)
		contentView.addSubview(usernameLabel)

		NSLayoutConstraint.activateConstraints([
			avatarView.topAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.topAnchor),
			avatarView.bottomAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.bottomAnchor),
			avatarView.leadingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.leadingAnchor),

			usernameLabel.centerYAnchor.constraintEqualToAnchor(avatarView.centerYAnchor),
			usernameLabel.leadingAnchor.constraintEqualToAnchor(avatarView.trailingAnchor, constant: 16),
			usernameLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


extension UserCell: CellType {
	func configure(row row: Row) {
		usernameLabel.text = row.text
		avatarView.user = row.context?["user"] as? User
	}
}
