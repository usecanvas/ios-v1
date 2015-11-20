//
//  Heading.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Heading: Prefixable {

	// MARK: - Types

	public enum Level: UInt {
		case One = 1
		case Two = 2
		case Three = 3
		case Four = 4
		case Five = 5
		case Six = 6
	}


	// MARK: - Properties

	public var prefixRange: NSRange
	public var contentRange: NSRange
	public var level: Level


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

		self.prefixRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

		// Content
		self.contentRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)
	}
}
