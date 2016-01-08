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

	public var isFilled: Bool {
		return rawValue % 2 == 0
	}

	public var successor: Indentation {
		if self == .Seven {
			return self
		}

		return Indentation(rawValue: rawValue + 1)!
	}

	public var predecessor: Indentation {
		if self == .Zero {
			return self
		}

		return Indentation(rawValue: rawValue - 1)!
	}

	public var string: String {
		return rawValue.description
	}
}


public protocol Listable: NativePrefixable {
	var indentation: Indentation { get }
	var indentationRange: NSRange { get }
}


func parseListable(string string: String, enclosingRange: NSRange, delimiter: String, prefix: String) -> (nativePrefixRange: NSRange, indentationRange: NSRange, indentation: Indentation, prefixRange: NSRange, contentRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString(leadingNativePrefix, intoString: nil) {
		return nil
	}

	if !scanner.scanString("\(delimiter)-", intoString: nil) {
		return nil
	}

	let indentationRange = NSRange(location:  enclosingRange.location + scanner.scanLocation, length: 1)
	var indent = -1
	if !scanner.scanInteger(&indent) {
		return nil
	}

	guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
		return nil
	}

	if !scanner.scanString(trailingNativePrefix, intoString: nil) {
		return nil
	}

	let nativePrefixRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

	// Prefix
	let startPrefix = scanner.scanLocation
	if !scanner.scanString(prefix, intoString: nil) {
		return nil
	}

	let prefixRange = NSRange(location: enclosingRange.location + startPrefix, length: scanner.scanLocation - startPrefix)

	// Content
	let contentRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

	return (nativePrefixRange, indentationRange, indentation, prefixRange, contentRange)
}
