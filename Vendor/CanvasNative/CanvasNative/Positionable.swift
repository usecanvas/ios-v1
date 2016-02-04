//
//  Positionable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/3/16.
//  Copyright © 2016 Canvas Labs Inc. All rights reserved.
//

public struct Position: OptionSetType, CustomStringConvertible {
	public let rawValue: Int
	public init(rawValue: Int) { self.rawValue = rawValue }

	public static let Top = Position(rawValue: 1)
	public static let Middle = Position(rawValue: 2)
	public static let Bottom = Position(rawValue: 3)
	public static let Single: Position = [Top, Middle, Bottom]

	public var description: String {
		if self == Position.Top {
			return "Top"
		}

		if self == Position.Bottom {
			return "Bottom"
		}

		if self == Position.Single {
			return "Single"
		}

		return "Middle"
	}
}


public protocol Positionable {
	var position: Position { get set }
}
