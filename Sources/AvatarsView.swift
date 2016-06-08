//
//  AvatarsView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit

final class AvatarsView: UIStackView {

	// MARK: - Properties

	var users = [User]() {
		didSet {
			arrangedSubviews.forEach { $0.removeFromSuperview() }

			for user in users {
				let view = AvatarView(user: user)
				addArrangedSubview(view)
			}
		}
	}
	

	// MARK: - Initializers

	convenience init() {
		self.init(frame: .zero)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		axis = .Vertical
		spacing = 8
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
