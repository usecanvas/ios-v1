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
			let nextSibling = textStorage.nextBlockNodeAfterBlockAtDisplayLocation(index)
			let spacing = textStorage.theme.blockSpacing(node: node, nextSibling: nextSibling, horizontalSizeClass: textStorage.horizontalSizeClass)
			rect = spacing.applyPadding(rect)
		}

		return super.lineFragmentRectForProposedRect(rect, atIndex: index, writingDirection: writingDirection, remainingRect: remainingRect)
	}
}
