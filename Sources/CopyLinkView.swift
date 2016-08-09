//
//  CopyLinkView.swift
//  Canvas
//
//  Created by Sam Soffes on 8/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

// TODO: Localize
final class CopyLinkView: UIStackView {

	// MARK: - Properties

	let button: UIButton = {
		let button = GrayButton()
		button.setTitle("Copy Link", forState: .Normal)
		return button
	}()


	// MARK: - Initializers

	init() {
		super.init(frame: .zero)

		axis = .Vertical
		alignment = .Center
		spacing = 16

		let label = UILabel()
		label.text = "Invite more participants"
		label.textColor = Swatch.gray
		addArrangedSubview(label)

		addArrangedSubview(button)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
