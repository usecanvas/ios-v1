//
//  CanvasTextContainer.swift
//  CanvasText
//
//  Created by Sam Soffes on 2/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative

public class CanvasTextContainer: NSTextContainer {
	public override func lineFragmentRectForProposedRect(proposedRect: CGRect, atIndex index: Int, writingDirection: NSWritingDirection, remainingRect: UnsafeMutablePointer<CGRect>) -> CGRect {
		var rect = proposedRect

		if let textStorage = layoutManager?.textStorage as? CanvasTextStorage, node = textStorage.blockNodeAtDisplayLocation(index) {
			let spacing = textStorage.theme.blockSpacing(node: node, horizontalSizeClass: textStorage.horizontalSizeClass)
			rect = spacing.applyPadding(rect)

			// Apply the top margin if it's not the second node
			if spacing.marginTop > 0 && textStorage.nodes.count >= 2 && node.range.location > textStorage.nodes[1].range.location {
				rect.origin.y += spacing.marginTop
			}
		}

		return super.lineFragmentRectForProposedRect(rect, atIndex: index, writingDirection: writingDirection, remainingRect: remainingRect)
	}
}
