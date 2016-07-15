//
//  BillboardView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/5/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

final class BillboardView: UIStackView {
	
	// MARK: - Properties
	
	let illustrationView = UIImageView()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.black
		return label
	}()
	
	let subtitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.darkGray
		label.numberOfLines = 0
		label.textAlignment = .Center
		return label
	}()
	
	
	// MARK: - Initializers
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		axis = .Vertical
		alignment = .Center
		layoutMargins = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
		layoutMarginsRelativeArrangement = true
		
		addArrangedSubview(illustrationView)
		addSpace(32)
		addArrangedSubview(titleLabel)
		addSpace(8)
		addArrangedSubview(subtitleLabel)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFonts), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFonts()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - Private
	
	@objc private func updateFonts() {
		titleLabel.font = TextStyle.title1.font()
		subtitleLabel.font = TextStyle.body.font()
	}
}
