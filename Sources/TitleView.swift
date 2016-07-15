//
//  TitleView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class TitleView: UIView {
	
	// MARK: - Properties
	
	var showsLock = false {
		didSet {
			lockView.hidden = !showsLock
			setNeedsLayout()
		}
	}

	var title = "" {
		didSet {
			titleLabel.text = title
			setNeedsLayout()
		}
	}
	
	private let lockView: UIImageView = {
		let view = UIImageView(image: UIImage(named: "Lock"))
		view.tintColor = Swatch.darkGray
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.darkGray
		label.font = Font.sansSerif(weight: .medium)
		return label
	}()
	
	private let spacing: CGFloat = 4
	
	
	// MARK: - Initializers
	
	init() {
		super.init(frame: .zero)
		
		autoresizingMask = [.FlexibleWidth]
		
		lockView.sizeToFit()
		
		addSubview(lockView)
		addSubview(titleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIView
	
	override class func layerClass() -> AnyClass {
		return CATransformLayer.self
	}
	
	override func layoutSubviews() {
		let size = bounds.size
		let titleSize = titleLabel.sizeThatFits(size)
		var titleFrame = CGRect(x: round((size.width - titleSize.width) / 2), y: round((size.height - titleSize.height) / 2), width: titleSize.width, height: titleSize.height)
		
		if showsLock {
			let lockSize = lockView.bounds.size
			titleFrame.origin.x += round((lockSize.width + spacing) / 2)
			lockView.frame = CGRect(x: titleFrame.origin.x - lockSize.width - spacing, y: round((size.height - lockSize.height) / 2), width: lockSize.width, height: lockSize.height)
		}
		
		if titleFrame.maxX > bounds.width {
			if showsLock {
				lockView.frame.origin.x = 0
				titleFrame.origin.x = lockView.frame.maxX + spacing
			} else {
				titleFrame.origin.x = 0
			}
			
			titleFrame.size.width = bounds.width - titleFrame.minX
		}
		
		titleLabel.frame = titleFrame
	}
}
