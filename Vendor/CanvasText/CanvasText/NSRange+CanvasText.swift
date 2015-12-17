//
//  NSRange+CanvasText.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSRange: Equatable {

	// MARK: - Properties

	public var max: Int {
		return NSMaxRange(self)
	}

	public static var zero: NSRange {
		return NSRange(location: 0, length: 0)
	}

	
	// MARK: - Initializers

	public init(location: UInt, length: UInt) {
		self.init(location: Int(location), length: Int(length))
	}
	
	public init(location: UInt, length: Int) {
		self.init(location: Int(location), length: length)
	}
	
	public init(location: Int, length: UInt) {
		self.init(location: location, length: Int(length))
	}


	// MARK: - Working with other Ranges

	public func union(range: NSRange) -> NSRange {
		return NSUnionRange(self, range)
	}

	/// Returns nil if they don't intersect. Their intersection may be 0 if one of the ranges has a zero length.
	public func intersection(range: NSRange) -> Int? {
		if range.length == 0 {
			return NSLocationInRange(range.location, self) ? 0 : nil
		}

		let length = NSIntersectionRange(self, range).length
		return length > 0 ? length : nil
	}
}


public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
	return NSEqualRanges(lhs, rhs)
}
