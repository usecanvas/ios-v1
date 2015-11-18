//
//  TextView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

class TextView: UITextView {

	// MARK: - Properties

	private var annotations = [UIView]()

	override var attributedText: NSAttributedString? {
		didSet {
			annotations.forEach { $0.removeFromSuperview() }
			annotations.removeAll()

			guard let attributedText = attributedText else { return }

			let bounds = NSRange(location: 0, length: attributedText.length)
			attributedText.enumerateAttribute("Canvas.Block", inRange: bounds, options: [.LongestEffectiveRangeNotRequired]) { [weak self] value, range, _ in
				guard let this = self, kindString = value as? String, kind = Block.Kind(rawValue: kindString) else { return }

				guard let start = this.positionFromPosition(this.beginningOfDocument, offset: range.location),
					end = this.positionFromPosition(start, offset: range.length),
					textRange = this.textRangeFromPosition(start, toPosition: end)
					else { return }

				var rect = this.firstRectForRange(textRange)

				switch kind {
				case .UnorderedList:
					rect.origin.x -= 24
					rect.origin.y += 6
					rect.size = CGSize(width: 9, height: 9)
					
					let view = BulletView(frame: rect)				
					self?.annotations.append(view)
					self?.addSubview(view)

				case .Checklist:
					rect.origin.x -= 24
					rect.origin.y += 3
					rect.size = CGSize(width: 16, height: 16)

					let view = CheckboxView(frame: rect)
					self?.annotations.append(view)
					self?.addSubview(view)

				default: return
				}
			}
		}
	}


	// MARK: - Initializers

	convenience init() {
		self.init(frame: .zero, textContainer: nil)
		tintColor = Color.brand
	}
}
