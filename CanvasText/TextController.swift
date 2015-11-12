//
//  TextController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol TextControllerDelegate: class {
	func textControllerDidChangeText(textController: TextController)
	func textControllerDidUpdateSelection(textController: TextController)
}


public class TextController {
	
	// MARK: - Properties
	
	public var backingText: String {
		didSet {
			backingTextDidChange()
		}
	}
	
	public var backingSelection: NSRange {
		didSet {
			displaySelection = backingRangeToDisplayRange(backingSelection)
			delegate?.textControllerDidUpdateSelection(self)
		}
	}
	
	public private(set) var displayText: String
	
	public private(set) var displaySelection: NSRange
	
	public private(set) var lines = [Line]()
	
	public weak var delegate: TextControllerDelegate?
	
	private var otController: OTController?
	
	
	// MARK: - Initializers
	
	public init(backingText: String = "", delegate: TextControllerDelegate? = nil) {
		self.backingText = backingText
		self.delegate = delegate

		backingSelection = .zero
		displayText = ""
		displaySelection = .zero
		backingTextDidChange()
	}
	
	
	// MARK: - Realtime
	
	public func connect(collectionID collectionID: String, canvasID: String) {
		otController = OTController(collectionID: collectionID, canvasID: canvasID)
		otController?.delegate = self
	}
	
	
	// MARK: - Editing
	
	public func change(range range: NSRange, replacementText text: String) {
		let backingRange = displayRangeToBackingRange(range)
		
		// Insert
		if range.length == 0 {
			otController?.submitOperation(.Insert(location: UInt(backingRange.location), string: text))
		}
			
		// Remove
		else {
			otController?.submitOperation(.Remove(location: UInt(backingRange.location), length: UInt(backingRange.length)))
		}
	}
	
	
	// MARK: - Ranges
	
	public func backingRangeToDisplayRange(backingRange: NSRange) -> NSRange {
		var displayRange = backingRange
		
		for delimiter in lines.flatMap({ $0.delimiterRange }) {
			if delimiter.location > backingRange.location {
				break
			}
			
			displayRange.location -= delimiter.length
		}

		for prefix in lines.flatMap({ $0.prefixRange }) {
			if prefix.location > backingRange.location {
				break
			}

			displayRange.location -= prefix.length
		}
		
		return displayRange
	}
	
	public func displayRangeToBackingRange(displayRange: NSRange) -> NSRange {
		var backingRange = displayRange
		
		for delimiter in lines.flatMap({ $0.delimiterRange }) {
			if delimiter.location > backingRange.location {
				break
			}
			
			backingRange.location += delimiter.length
		}

		for prefix in lines.flatMap({ $0.prefixRange }) {
			if prefix.location > backingRange.location {
				break
			}

			backingRange.location += prefix.length
		}
		
		return backingRange
	}
	
	
	// MARK: - Private
	
	private func backingTextDidChange() {
		// Convert to Foundation string so we can work with `NSRange` instead of `Range` since the TextKit APIs take
		// `NSRange` instead `Range`. Bummer.
		let text = backingText as NSString
		
		// We're going to rebuild `lines` and `displayText` from the new `backingText`.
		var lines = [Line]()
		
		// Enumerate the string lines of the `backingText`.
		text.enumerateSubstringsInRange(NSRange(location: 0, length: text.length), options: [.ByLines]) { [weak self] substring, substringRange, _, _ in
			// Ensure we have a substring to work with
			guard let substring = substring else { return }
			let offset = substringRange.location
			
			// Setup a scanner
			let scanner = NSScanner(string: substring)
			scanner.charactersToBeSkipped = nil

			var line = Line(kind: .Paragraph, contentRange: substringRange)

			// Look for a delimiter
			if scanner.scanString(Line.leadingDelimiter, intoString: nil) {
				var blockName: NSString?
				scanner.scanUpToString(Line.trailingDelimiter, intoString: &blockName)
			
				if let blockName = blockName as? String, k = Line.Kind(rawValue: blockName) where scanner.scanString(Line.trailingDelimiter, intoString: nil) {
					line.kind = k
					line.delimiterRange = NSRange(location: offset, length: scanner.scanLocation)
				}
			}

			// Look for a prefix
			if let delimiter = line.delimiterRange, prefix = line.kind.prefix where scanner.scanString(prefix, intoString: nil) {
				line.prefixRange = NSRange(location: delimiter.max, length: prefix.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
			}

			// Look for headers
			if line.kind == .Paragraph, let heading = self?.parseHeadings(scanner: scanner, offset: offset, line: line) {
				line = heading
			}

			if line.kind != .Paragraph {
				let delimiter = line.delimiterRange ?? .zero
				let prefix = line.prefixRange ?? .zero
				line.contentRange = NSRange(location: offset + delimiter.length + prefix.length, length: substringRange.length - delimiter.length - prefix.length)
			}

			lines.append(line)
		}
		
		self.lines = lines
		displayText = lines.map { $0.contentInString(backingText) }.joinWithSeparator("\n")
		
		delegate?.textControllerDidChangeText(self)
	}

	private func parseHeadings(scanner scanner: NSScanner, offset: Int, line: Line) -> Line? {
		let location = scanner.scanLocation
		var hashes: NSString?

		guard scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: "#"), intoString: &hashes) && scanner.scanString(" ", intoString: nil) else {
			scanner.scanLocation = location
			return nil
		}

		guard let h = hashes, k = Line.Kind(headingLevel: UInt(h.length)) else {
			scanner.scanLocation = location
			return nil
		}

		var heading = line
		heading.kind = k
		heading.prefixRange = NSRange(location: offset + location, length: scanner.scanLocation - location)
		return heading
	}
}


extension TextController: OTControllerDelegate {
	func otController(controller: OTController, didReceiveSnapshot text: String) {
		backingText = text
	}
	
	func otController(controller: OTController, didReceiveOperation operation: Operation) {
		var backingText = self.backingText
		var backingSelection = self.backingSelection
		
		switch operation {
		case .Insert(let location, let string):
			// Shift selection
			let length = string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			if Int(location) < backingSelection.location {
				backingSelection.location += string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			}
			
			// Extend selection
			backingSelection.length += NSIntersectionRange(backingSelection, NSRange(location: location, length: length)).length
			
			// Update text
			let index = backingText.startIndex.advancedBy(Int(location))
			let range = Range<String.Index>(start: index, end: index)
			backingText = backingText.stringByReplacingCharactersInRange(range, withString: string)
		case .Remove(let location, let length):
			// Shift selection
			if Int(location) < backingSelection.location {
				backingSelection.location -= Int(length)
			}
			
			// Extend selection
			backingSelection.length -= NSIntersectionRange(backingSelection, NSRange(location: location, length: length)).length
			
			// Update text
			let index = backingText.startIndex.advancedBy(Int(location))
			let range = Range<String.Index>(start: index, end: index.advancedBy(Int(length)))
			backingText = backingText.stringByReplacingCharactersInRange(range, withString: "")
		}
		
		// Apply changes
		self.backingText = backingText
		self.backingSelection = backingSelection
	}
}
