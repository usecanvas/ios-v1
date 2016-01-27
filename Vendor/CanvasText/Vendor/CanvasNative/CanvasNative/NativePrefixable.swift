//
//  NativePrefixable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

let leadingNativePrefix = "⧙"
let trailingNativePrefix = "⧘"

public protocol NativePrefixable: BlockNode {
	var nativePrefixRange: NSRange { get }
}


func parseBlockNode(string string: String, enclosingRange: NSRange, delimiter: String, prefix: String) -> (nativePrefixRange: NSRange, prefixRange: NSRange, displayRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingNativePrefix)\(delimiter)\(trailingNativePrefix)", intoString: nil) {
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
	let displayRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

	return (nativePrefixRange, prefixRange, displayRange)
}


func parseBlockNode(string string: String, enclosingRange: NSRange, delimiter: String) -> (nativePrefixRange: NSRange, displayRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingNativePrefix)\(delimiter)\(trailingNativePrefix)", intoString: nil) {
		return nil
	}
	let nativePrefixRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

	// Content
	let displayRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

	return (nativePrefixRange, displayRange)
}
