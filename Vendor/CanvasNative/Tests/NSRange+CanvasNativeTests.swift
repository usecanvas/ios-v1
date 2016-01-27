//
//  NSRange+CanvasNativeTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/22/16.
//  Copyright © 2016 Canvas Labs Inc. All rights reserved.
//

import Foundation

extension NSRange: Equatable {}

public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
	return NSEqualRanges(lhs, rhs)
}
