//
//  Listable.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public enum Indentation: UInt {
	case Zero = 0
	case One = 1
	case Two = 2
	case Three = 3
}


public protocol Listable: Node {
	var indentation: Indentation { get }
}
