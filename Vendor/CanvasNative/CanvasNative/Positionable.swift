//
//  Positionable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/3/16.
//  Copyright © 2016 Canvas Labs Inc. All rights reserved.
//

public enum Position: String {
	case Top
	case Middle
	case Bottom
	case Single

	public var isTop: Bool {
		return self == .Top || self == .Single
	}

	public var isBottom: Bool {
		return self == .Bottom || self == .Single
	}
}


public protocol Positionable {
	var position: Position { get set }
}
