//
//  CanvasTextView+Folding.swift
//  Canvas
//
//  Created by Sam Soffes on 1/20/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

extension CanvasTextView: NSLayoutManagerDelegate {
	func updateFolding() {
		let range = NSRange(location: 0, length: textStorage.length)
		layoutManager.invalidateGlyphsForCharacterRange(range, changeInLength: 0, actualCharacterRange: nil)
	}

	func layoutManager(layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes: UnsafePointer<Int>, font: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
		guard let textStorage = textStorage as? CanvasTextStorage else { return 0 }

		let properties = UnsafeMutablePointer<NSGlyphProperty>(props)

		// TODO: Cache this
		let foldableNodes = textStorage.nodesInBackingRange(textStorage.displayRangeToBackingRange(selectedRange)).filter { node in
			return node is Foldable
		}

		for i in 0..<glyphRange.length {
			let characterIndex = characterIndexes[i]

			// Skip if the selection is in a foldable node
			var skip = false
			for node in foldableNodes {
				if textStorage.backingRangeToDisplayRange(node.range).contains(characterIndex) {
					skip = true
					break
				}
			}

			if skip {
				continue
			}

			if textStorage.attributesAtIndex(characterIndex, effectiveRange: nil)[FoldableAttributeName] as? Bool == true {
				properties[i] = .ControlCharacter
				updatedFolding = true
			}
		}

		layoutManager.setGlyphs(glyphs, properties: properties, characterIndexes: characterIndexes, font: font, forGlyphRange: glyphRange)
		return glyphRange.length
	}

	func layoutManager(layoutManager: NSLayoutManager, shouldUseAction action: NSControlCharacterAction, forControlCharacterAtIndex characterIndex: Int) -> NSControlCharacterAction {
		if textStorage.attributesAtIndex(characterIndex, effectiveRange: nil)[FoldableAttributeName] as? Bool == true {
			return .ZeroAdvancement
		}
		return action
	}

	func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
		// This is totally stupid.
		if updatedFolding {
			textContainer?.replaceLayoutManager(layoutManager)
			updatedFolding = false
		}
	}
}
