//
//  Delimitable.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

let leadingDelimiter = "⧙"
let trailingDelimiter = "⧘"

public protocol Delimitable: Node {
	var delimiterRange: NSRange { get }
}


func parseBlockNode(string string: String, enclosingRange: NSRange, delimiter: String, prefix: String) -> (delimiterRange: NSRange, prefixRange: NSRange, contentRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingDelimiter)\(delimiter)\(trailingDelimiter)", intoString: nil) {
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

	return (delimiterRange, prefixRange, contentRange)
}


func parseBlockNode(string string: String, enclosingRange: NSRange, delimiter: String) -> (delimiterRange: NSRange, contentRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingDelimiter)\(delimiter)\(trailingDelimiter)", intoString: nil) {
		return nil
	}
	let delimiterRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

	// Content
	let contentRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

	return (delimiterRange, contentRange)
}
