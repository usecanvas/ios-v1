//
//  NSRange+CanvasNative.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSRange {

	// MARK: - Properties

	var max: Int {
		return NSMaxRange(self)
	}

	static var zero: NSRange {
		return NSRange(location: 0, length: 0)
	}

	var dictionary: [String: AnyObject] {
		return [
			"location": location,
			"length": length
		]
	}

	
	// MARK: - Initializers

	init(location: UInt, length: UInt) {
		self.init(location: Int(location), length: Int(length))
	}
	
	init(location: UInt, length: Int) {
		self.init(location: Int(location), length: length)
	}
	
	init(location: Int, length: UInt) {
		self.init(location: location, length: Int(length))
	}


	// MARK: - Working with Locations

	func contains(location: UInt) -> Bool {
		return contains(Int(location))
	}

	func contains(location: Int) -> Bool {
		return NSLocationInRange(location, self)
	}


	// MARK: - Working with other Ranges

	func union(range: NSRange) -> NSRange {
		return NSUnionRange(self, range)
	}

	/// Returns nil if they don't intersect. Their intersection may be 0 if one of the ranges has a zero length.
	///
	/// - parameter range: The range to check for intersection with the receiver.
	/// - return: The length of intersection if they intersect or nil if they don't.
	func intersection(range: NSRange) -> Int? {
		if range.length == 0 {
			return NSLocationInRange(range.location, self) ? 0 : nil
		}

		let length = NSIntersectionRange(self, range).length
		return length > 0 ? length : nil
	}
}
