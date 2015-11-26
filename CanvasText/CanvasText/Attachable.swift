//
//  Attachable.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Attachable: Delimitable {}

extension Attachable {
	public var contentRange: NSRange {
		return NSRange(location: delimiterRange.max, length: 1)
	}
}
