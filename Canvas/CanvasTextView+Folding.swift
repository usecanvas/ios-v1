//
//  CanvasTextView+Folding.swift
//  Canvas
//
//  Created by Sam Soffes on 1/20/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText
import CanvasNative

extension CanvasTextView {

	// MARK: - Folding

	func updateFolding() {
		guard let layoutManager = textContainer.layoutManager as? FoldingLayoutManager else { return }
		layoutManager.unfoldedRange = unfoldableRange(displaySelection: selectedRange)
		updatedFolding = true
	}


	// MARK: - Private

	/// Expand selection to the entire node
	private func unfoldableRange(displaySelection displaySelection: NSRange) -> NSRange? {
		guard let textStorage = textStorage as? CanvasTextStorage else { return displaySelection }

		let selectedRange: NSRange = {
			var range = displaySelection
			range.location = max(0, range.location - 1)
			range.length += (displaySelection.location - range.location) + 1
			return textStorage.displayRangeToBackingRange(range)
		}()

		let foldableNodes = textStorage.nodesInBackingRange(selectedRange).filter { $0 is Foldable }
		var foldableRanges = ArraySlice<NSRange>(foldableNodes.map { textStorage.backingRangeToDisplayRange($0.range) })

		guard var range = foldableRanges.popFirst() else { return nil }

		for r in foldableRanges {
			range = range.union(r)
		}

		return range
	}
}


extension CanvasTextView: FoldingLayoutManagerDelegate {
	func layoutManager(layoutManager: NSLayoutManager, didInvalidateGlyphs glyphRange: NSRange) {
		updatingFolding = true
	}

	func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer) {
		if updatingFolding {
			textContainer.replaceLayoutManager(layoutManager)
			updatingFolding = false
		}

		removeAnnotations()
		updateAnnotations()
		
		updatingFolding = false
	}
}
