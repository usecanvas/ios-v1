//
//  NodeContainer.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol NodeContainer: Node {
	/// Range of text to parse inline elements
	var textRange: NSRange { get }

	/// Nodes for inline elements
	var subnodes: [Node] { get set }
}
