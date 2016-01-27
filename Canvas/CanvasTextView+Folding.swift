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
<<<<<<< Updated upstream
		let range = NSRange(location: 0, length: textStorage.length)
		layoutManager.invalidateGlyphsForCharacterRange(range, changeInLength: 0, actualCharacterRange: nil)
		updatedFolding = true
=======
		guard let layoutManager = textContainer.layoutManager as? FoldingLayoutManager else { return }
		layoutManager.unfoldedRange = unfoldableRange(displaySelection: selectedRange)
>>>>>>> Stashed changes
	}

	func layoutManager(layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes: UnsafePointer<Int>, font: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
		guard let textStorage = textStorage as? CanvasTextStorage else { return 0 }

		let properties = UnsafeMutablePointer<NSGlyphProperty>(props)

		// Expand range
		var selectedRange = self.selectedRange
		selectedRange.location = max(0, selectedRange.location - 1)
		selectedRange.length += (self.selectedRange.location - selectedRange.location) + 1
		selectedRange = textStorage.displayRangeToBackingRange(selectedRange)

		// TODO: Cache this
		let foldableNodes = textStorage.nodesInBackingRange(selectedRange).filter { node in
			return node is Foldable
		}

		for i in 0..<glyphRange.length {
			let characterIndex = characterIndexes[i]

			// Skip if the selection is in a foldable node
			var skip = false
			for node in foldableNodes {
				let nodeRange = textStorage.backingRangeToDisplayRange(node.range)
				if nodeRange.contains(characterIndex) || nodeRange.max + 1 == characterIndex {
					skip = true
					break
				}
			}

			if skip {
				continue
			}

			if textStorage.attributesAtIndex(characterIndex, effectiveRange: nil)[FoldableAttributeName] as? Bool == true {
				properties[i] = .ControlCharacter
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

		removeAnnotations()
		updateAnnotations()
	}
}
