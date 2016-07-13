//
//  FooterButton.swift
//  Canvas
//
//  Created by Sam Soffes on 7/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class FooterButton: PrefaceButton {
	
	// MARK: - Properties
	
	let lineView: LineView = {
		let view = LineView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	
	// MARK: - Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(lineView)
		
		NSLayoutConstraint.activateConstraints([
			lineView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			lineView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			lineView.topAnchor.constraintEqualToAnchor(topAnchor),
			
			heightAnchor.constraintEqualToConstant(48)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
