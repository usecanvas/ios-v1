//
//  Delimitable.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

let leadingDelimiter = "⧙"
let trailingDelimiter = "⧘"

public protocol Delimitable: Node {
	var delimiterRange: NSRange { get }
}
