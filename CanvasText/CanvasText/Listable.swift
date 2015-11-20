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
	case Four = 4
	case Five = 5
	case Six = 6
	case Seven = 7
}


public protocol Listable: Delimitable, Prefixable {
	var indentation: Indentation { get }
}


func parseListable(string string: String, enclosingRange: NSRange, delimiter: String, prefix: String) -> (delimiterRange: NSRange, indentation: Indentation, prefixRange: NSRange, contentRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString(leadingDelimiter, intoString: nil) {
		return nil
	}

	if !scanner.scanString("\(delimiter)-", intoString: nil) {
		return nil
	}

	var indent = -1
	if !scanner.scanInteger(&indent) {
		return nil
	}

	guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
		return nil
	}

	if !scanner.scanString(trailingDelimiter, intoString: nil) {
		return nil
	}

	let delimiterRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

	// Prefix
	let startPrefix = scanner.scanLocation
	if !scanner.scanString(prefix, intoString: nil) {
		return nil
	}

	let prefixRange = NSRange(location: enclosingRange.location + startPrefix, length: scanner.scanLocation - startPrefix)

	// Content
	let contentRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

	return (delimiterRange, indentation, prefixRange, contentRange)
}
