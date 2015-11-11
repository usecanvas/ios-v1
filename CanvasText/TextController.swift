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
		
		for delimiter in lines.flatMap({ $0.delimiter }) {
			if delimiter.location > backingRange.location {
				break
			}
			
			displayRange.location -= delimiter.length
		}
		
		return displayRange
	}
	
	public func displayRangeToBackingRange(displayRange: NSRange) -> NSRange {
		var backingRange = displayRange
		
		for delimiter in lines.flatMap({ $0.delimiter }) {
			if delimiter.location > backingRange.location {
				break
			}
			
			backingRange.location += delimiter.length
		}
		
		return backingRange
	}
	
	
	// MARK: - Private
	
	private func backingTextDidChange() {
		var lines = [Line]()
		
		let text = backingText as NSString
		text.enumerateSubstringsInRange(NSRange(location: 0, length: text.length), options: [.ByLines]) { substring, substringRange, _, _ in
			guard let substring = substring else { return }
			
			let scanner = NSScanner(string: substring)
			scanner.charactersToBeSkipped = nil
			if !scanner.scanString(Line.leadingDelimiter, intoString: nil) {
				lines.append(Line(kind: .Paragraph, content: substringRange))
				return
			}
			
			var blockName: NSString?
			scanner.scanUpToString(Line.trailingDelimiter, intoString: &blockName)
			
			if !scanner.scanString(Line.trailingDelimiter, intoString: nil) {
				lines.append(Line(kind: .Paragraph, content: substringRange))
				return
			}
			
			guard let name = blockName as? String, kind = Line.Kind(rawValue: name) else {
				lines.append(Line(kind: .Paragraph, content: substringRange))
				return
			}
			
			let offset = substringRange.location
			let delimiter = NSRange(location: offset, length: scanner.scanLocation)			
			let content = NSRange(location: offset + delimiter.length, length: substringRange.length - delimiter.length)
			lines.append(Line(kind: kind, delimiter: delimiter, content: content))
		}
		
		self.lines = lines
		displayText = lines.map { $0.contentInString(backingText) }.joinWithSeparator("\n")
		
		delegate?.textControllerDidChangeText(self)
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
