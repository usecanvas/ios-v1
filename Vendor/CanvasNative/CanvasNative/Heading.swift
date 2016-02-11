//
//  Heading.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Heading: BlockNode, NodeContainer, Foldable {

	// MARK: - Types

	public enum Level: UInt {
		case One = 1
		case Two = 2
		case Three = 3
		case Four = 4
		case Five = 5
		case Six = 6

		public var successor: Level {
			if self == .Six {
				return self
			}

			return Level(rawValue: rawValue + 1)!
		}

		public var predecessor: Level {
			if self == .One {
				return self
			}

			return Level(rawValue: rawValue - 1)!
		}
	}


	// MARK: - Properties

	public var range: NSRange
	public var displayRange: NSRange
	public var foldableRanges: [NSRange]
	public var leadingDelimiterRange: NSRange
	public var textRange: NSRange
	public var level: Level
	public let allowsReturnCompletion = false

	public var subnodes = [Node]()


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Prefix
		var hashes: NSString? = ""
		if !scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: "#"), intoString: &hashes) {
			return nil
		}

		guard let count = hashes?.length, level = Level(rawValue: UInt(count)) else { return nil }
		self.level = level

		if !scanner.scanString(" ", intoString: nil) {
			return nil
		}

		leadingDelimiterRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)
		foldableRanges = [leadingDelimiterRange]

		// Content
		textRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)
		range = enclosingRange
		displayRange = range
	}


	// MARK: - Native

	public static func nativeRepresentation(level level: Level = .One) -> String {
		var prefix = ""

		for _ in 0..<level.rawValue {
			prefix += "#"
		}

		prefix += " "

		return prefix
	}
}
