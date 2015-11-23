//
//  FontStyle.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct FontStyle: OptionSetType {
	public let rawValue: UInt
	public init(rawValue: UInt) { self.rawValue = rawValue }

	public static let Bold = FontStyle(rawValue: 1)
	public static let Italic = FontStyle(rawValue: 2)
}
