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
}


// TODO: Handle selection
// TODO: Hook up OT
// TODO: Hooks for UITextView
public class TextController {
	
	// MARK: - Properties
	
	public var backingText: String {
		didSet {
			backingTextDidChange()
		}
	}
	
	public private(set) var displayText: String
	
	public private(set) var lines = [Line]()
	
	public weak var delegate: TextControllerDelegate?
	
	
	// MARK: - Initializers
	
	public init(backingText: String = "", delegate: TextControllerDelegate? = nil) {
		self.backingText = backingText
		self.delegate = delegate

		displayText = ""
		backingTextDidChange()
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
