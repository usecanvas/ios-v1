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


	// MARK: - Combining

	public func union(range: NSRange) -> NSRange {
		return NSUnionRange(self, range)
	}
}


public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
	return NSEqualRanges(lhs, rhs)
}
