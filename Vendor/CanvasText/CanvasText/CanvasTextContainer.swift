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

		let textStorage = layoutManager?.textStorage as? CanvasTextStorage

		if let node = textStorage?.blockNodeAtDisplayLocation(index) {
			if node is Title {
				rect.origin.x += 100
				rect.size.width -= 100
			}
		}

		return super.lineFragmentRectForProposedRect(rect, atIndex: index, writingDirection: writingDirection, remainingRect: remainingRect)
	}
}
