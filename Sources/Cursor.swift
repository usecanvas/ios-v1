//
//  Cursor.swift
//  Canvas
//
//  Created by Sam Soffes on 6/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

struct Cursor {
	/// Index of line on which the user's cursor begins
	var startLine: UInt

	/// Index of user's cursor start on `startLine`
	var start: UInt

	/// Index of line on which user's cursor ends
	var endLine: UInt

	/// Index of user's cursor end on `endLine`
	var end: UInt

//	init?(selectedRange: NSRange, string: String) {
//		let text = string as NSString
//		let bounds = NSRange(location: 0, length: text.length)
//
//		if NSMaxRange(selectedRange) > bounds.length {
//			return nil
//		}
//	}
}
