//
//  ChecklistItem.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct ChecklistItem: Listable, NodeContainer {

	// MARK: - Types

	public enum Completion: String {
		case Incomplete = " "
		case Complete = "x"

		public var string: String {
			return rawValue
		}

		public var opposite: Completion {
			switch self {
			case .Incomplete: return .Complete
			case . Complete: return .Incomplete
			}
		}
	}


	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var displayRange: NSRange
	public var indentationRange: NSRange
	public var indentation: Indentation
	public var completedRange: NSRange
	public var completion: Completion
	public var position: Position = .Single

	public var hasAnnotation: Bool {
		return true
	}

	public var textRange: NSRange {
		return displayRange
	}

	public var subnodes = [Node]()


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString("\(leadingNativePrefix)checklist-", intoString: nil) {
			return nil
		}

		var indent = -1
		if !scanner.scanInteger(&indent) {
			return nil
		}

		let indentationRange = NSRange(location:  enclosingRange.location + scanner.scanLocation, length: 1)
		guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
			return nil
		}

		self.indentationRange = indentationRange
		self.indentation = indentation

		if !scanner.scanString(trailingNativePrefix, intoString: nil) {
			return nil
		}

		let nativePrefixRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)


		// Prefix
		let startPrefix = scanner.scanLocation
		if !scanner.scanString("- [", intoString: nil) {
			return nil
		}

		let set = NSCharacterSet(charactersInString: "x ")
		var completionString: NSString? = ""
		let completedRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: 1)
		if !scanner.scanCharactersFromSet(set, intoString: &completionString) {
			return nil
		}

		if let completionString = completionString as? String, completion = Completion(rawValue: completionString) {
			self.completion = completion
		} else {
			return nil
		}

		if !scanner.scanString("] ", intoString: nil) {
			return nil
		}

		let prefixRange = NSRange(location: enclosingRange.location + startPrefix, length: scanner.scanLocation - startPrefix)
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)

		// Content
		self.completedRange = completedRange
		displayRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

		range = enclosingRange
	}


	// MARK: - Native

	public static func nativeRepresentation(indentation indentation: Indentation = .Zero, completion: Completion = .Incomplete) -> String {
		return "\(leadingNativePrefix)checklist-\(indentation.string)\(trailingNativePrefix)- [\(completion.string)] "
	}
}
