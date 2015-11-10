//
//  TextController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol TextControllerDelegate: class {
//	func textController(textController: TextController, textDidChange text: String)
//	func textController(textController: TextController, displayTextDidChange displayText: String)
}

// TODO: Handle selection
// TODO: Hook up OT
// TODO: Hooks for UITextView
public class TextController {
	
	// MARK: - Properties
	
	public var text: String {
		didSet {
			textDidChange()
		}
	}
	
	public private(set) var displayText: String
	
	public private(set) var lines = [Line]()
	
	public weak var delegate: TextControllerDelegate?
	
	
	// MARK: - Initializers
	
	public init(text: String = "", delegate: TextControllerDelegate? = nil) {
		self.text = text
		self.delegate = delegate

		displayText = ""
		textDidChange()
	}
	
	
	// MARK: - Private
	
	private func textDidChange() {
		var lines = [Line]()
		
		let textRange = Range<String.Index>(start: text.startIndex, end: text.endIndex)
		text.enumerateSubstringsInRange(textRange, options: [.ByLines]) { substring, substringRange, enclosingRange, _ in
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
			
			let start = substringRange.startIndex
			let delimiter = Range<String.Index>(start: start, end: start.advancedBy(scanner.scanLocation))
			let content = Range<String.Index>(start: delimiter.endIndex, end: substringRange.endIndex)
			lines.append(Line(kind: kind, delimiter: delimiter, content: content))
		}
		
		self.lines = lines
		displayText = lines.map { $0.contentWithString(text) }.joinWithSeparator("\n")
	}
}
