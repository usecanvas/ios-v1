//
//  Prefixable.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Prefixable: BlockNode {
	var prefixRange: NSRange { get }
}
