//
//  Checklist.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Checklist: Listable, Delimitable, Prefixable {

	// MARK: - Properties

	public var delimiterRange: NSRange
	public var prefixRange: NSRange
	public var contentRange: NSRange
	public var indentation: Indentation
	public var completed: Bool


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString(leadingDelimiter, intoString: nil) {
			return nil
		}

		if !scanner.scanString("checklist-", intoString: nil) {
			return nil
		}

		var indent = -1
		if !scanner.scanInteger(&indent) {
			return nil
		}

		guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
			return nil
		}

		self.indentation = indentation

		if !scanner.scanString(trailingDelimiter, intoString: nil) {
			return nil
		}

		delimiterRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

		// Prefix
		let startPrefix = scanner.scanLocation
		if !scanner.scanString("- [", intoString: nil) {
			return nil
		}

		let set = NSCharacterSet(charactersInString: "x ")
		var completion: NSString? = ""
		if !scanner.scanCharactersFromSet(set, intoString: &completion) {
			return nil
		}

		if completion == "x" {
			completed = true
		} else if completion == " " {
			completed = false
		} else {
			return nil
		}

		if !scanner.scanString("] ", intoString: nil) {
			return nil
		}

		prefixRange = NSRange(location: enclosingRange.location + startPrefix, length: scanner.scanLocation - startPrefix)

		// Content
		contentRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)
	}
}
