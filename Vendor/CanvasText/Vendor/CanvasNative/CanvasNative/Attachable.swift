//
//  Attachable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Attachable: NativePrefixable {}

extension Attachable {
	public var displayRange: NSRange {
		return NSRange(location: nativePrefixRange.max, length: 1)
	}
}
