//
//  CodeBlockBackgroundView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/30/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

class CodeBlockBackgroundView: UIView {

	// MARK: - Types

	enum Position {
		case Top
		case Middle
		case Bottom
	}


	// MARK: - Properties

	let theme: Theme
	let lineNumber: UInt
	let position: Position

	private let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Color.gray
		label.textAlignment = .Right
		return label
	}()

	private let lineNumberWidth: CGFloat = 40


	// MARK: - Initializers

	init(frame: CGRect, theme: Theme, lineNumber: UInt, position: Position) {
		self.theme = theme
		self.lineNumber = lineNumber
		self.position = position

		super.init(frame: frame)

		textLabel.font = theme.monospaceFontOfSize(theme.fontSize)
		textLabel.text = lineNumber.description

		traitCollectionDidChange(nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }

		if traitCollection.horizontalSizeClass != .Regular {
			return
		}

		let path: CGPath?

		switch position {
		case .Top: path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 4, height: 4)).CGPath
		case .Bottom: path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSize(width: 4, height: 4)).CGPath
		default: path = nil
		}

		if let path = path {
			CGContextAddPath(context, path)
			CGContextClip(context)
		}

		CGContextSetFillColorWithColor(context, Color.codeBackground.CGColor)
		CGContextFillRect(context, bounds)

		CGContextSetFillColorWithColor(context, Color.lineNumbersBackground.CGColor)
		CGContextFillRect(context, CGRect(x: 0, y: 0, width: lineNumberWidth, height: bounds.height))
	}

	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		if traitCollection.horizontalSizeClass != .Regular {
			backgroundColor = Color.codeBackground
			textLabel.removeFromSuperview()
			return
		}

		backgroundColor = theme.backgroundColor

		if textLabel.superview == nil {
			addSubview(textLabel)

			// TODO: This is terrible
			let top: CGFloat = position == .Top ? 11.5 : 5.5

			NSLayoutConstraint.activateConstraints([
				textLabel.trailingAnchor.constraintEqualToAnchor(leadingAnchor, constant: lineNumberWidth - 6),
				textLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: top)
			])
		}

		setNeedsDisplay()
	}
}
