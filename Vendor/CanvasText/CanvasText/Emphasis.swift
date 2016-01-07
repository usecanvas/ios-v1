//
//  Emphasis.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public struct Emphasis: ContainerNode {

	public var range: NSRange
	public var contentRange: NSRange
	public var subnodes: [Node]

	public init?(string: String, enclosingRange: NSRange) {
		return nil
	}
}
