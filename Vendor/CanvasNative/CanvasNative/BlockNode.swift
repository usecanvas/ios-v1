//
//  BlockNode.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol BlockNode: Node {
	var hasAnnotation: Bool { get }
	var allowsReturnCompletion: Bool { get }

	init?(string: String, enclosingRange: NSRange)
}


extension BlockNode {
	public var hasAnnotation: Bool {
		return false
	}

	public var allowsReturnCompletion: Bool {
		return true
	}
}
