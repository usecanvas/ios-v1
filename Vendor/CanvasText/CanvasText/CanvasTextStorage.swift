//
//  CanvasTextStorage.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import WebKit
import CanvasNative

public protocol CanvasTextStorageDelegate: class {
	func textStorageWillUpdateNodes(textStorage: CanvasTextStorage)
	func textStorageDidUpdateNodes(textStorage: CanvasTextStorage)
	func textStorage(textStorage: CanvasTextStorage, attachmentForAttachable node: Attachable) -> NSTextAttachment?
}


public protocol CanvasWebDelegate: class {
	func textStorage(textStorage: CanvasTextStorage, willConnectWithWebView webView: WKWebView)
	func textStorageDidConnect(textStorage: CanvasTextStorage)
	func textStorage(textStorage: CanvasTextStorage, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?)
	func textStorage(textStorage: CanvasTextStorage, didDisconnectWithErrorMessage errorMessage: String?)
}


public class CanvasTextStorage: ShadowTextStorage {

	// MARK: - Properties

	public var theme: Theme {
		didSet {
			reprocess()
		}
	}

	public weak var canvasDelegate: CanvasTextStorageDelegate?
	public weak var webDelegate: CanvasWebDelegate?

	private var transportController: TransportController?
	private var loaded = false
	private var foldableRanges = [NSRange]()

	public private(set) var nodes = [BlockNode]()

	public var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified


	// MARK: - Initializers

	public init(theme: Theme) {
		self.theme = theme
		super.init(backingText: "")
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	#if os(OSX)
		public required init?(pasteboardPropertyList propertyList: AnyObject, ofType type: String) {
			fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
		}
	#endif


	// MARK: - NSTextStorage

	public override func replaceCharactersInRange(range: NSRange, withString str: String) {
		var displayRange = range

		let isDeleting = str.isEmpty

		if isDeleting {
			// TODO: If at the end of a line and the next line has an attachment, delete the entire next line
			// TODO: If at the beginning of a line and the previous line has an attachment, delete the entire previous line

			// Delete the entire line of any attachments
			enumerateAttribute(NSAttachmentAttributeName, inRange: range, options: []) { attachment, attachmentRange, _ in
				guard attachment != nil else { return }
				var lineRange = (self.string as NSString).lineRangeForRange(attachmentRange)

				// We want to delete the line before not the line after
				lineRange.location -= 1
				
				displayRange = displayRange.union(lineRange)
			}
		}

		super.replaceCharactersInRange(displayRange, withString: str)

		if !isDeleting {
			// Look for Markdown prefixes
			markdownCompletion(displayRange)
		}
	}

	public override func processEditing() {
		super.processEditing()

		// Invalidate the layout
		// TODO: Only do this if we need to
		let bounds = NSRange(location: 0, length: length)
		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.layoutManagers.forEach { $0.invalidateLayoutForCharacterRange(bounds, actualCharacterRange: nil) }
		}
	}


	// MARK: - ShadowTextStorage

	override public func replaceBackingCharactersInRange(range: NSRange, withString str: String) {
		var backingRange = range
		var replacement = str

		// Return completion
		if replacement == "\n" {
			// Continue the previous node
			if let node = blockNodeAtBackingLocation(backingRange.location) where node.allowsReturnCompletion {
				// Bust out of completion
				if node.displayRange.length == 0 {
					backingRange = node.range
					replacement = ""
				} else {
					// Complete the node
					if let node = node as? NativePrefixable {
						replacement += (backingText as NSString).substringWithRange(node.nativePrefixRange)

						// Make checkboxes unchecked by default
						replacement = replacement.stringByReplacingOccurrencesOfString("- [x] ", withString: "- [ ] ")
					}
				}
			}

			// Code block
			else {
				let text = backingText as NSString
				let line = text.lineRangeForRange(range)

				if text.substringWithRange(line) == "```" {
					backingRange = line.union(range)
					replacement = CodeBlock.nativeRepresentation()
				}
			}
		}

		// Replace backing text
		super.replaceBackingCharactersInRange(backingRange, withString: replacement)

		// Ensure transport controller is available
		guard let transportController = transportController else {
			print("[CanvasText.TextStorage] Tried to submit operation without transport controller.")
			return
		}

		// Submit the operation
		// Insert
		if backingRange.length == 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: replacement))
			return
		}

		// Remove
		transportController.submitOperation(.Remove(location: UInt(backingRange.location), length: UInt(backingRange.length)))

		// Insert after removing
		if backingRange.length > 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: replacement))
		}
	}

	public override func shadowsForBackingText(backingText: String) -> [NSRange] {
		if !loaded {
			return []
		}

		// Parse nodes
		let parser = Parser(string: backingText)
		nodes = parser.parse()

		// Derive shadows from nodes
		return nodes.flatMap { node in
			guard let prefixable = node as? NativePrefixable else { return nil }
			return prefixable.nativePrefixRange
		}
	}

	/// Optionally add attributes to the display version of the text.
	public override func updateAttributes() {
		guard loaded else { return }

		setAttributes(theme.baseAttributes, range: NSRange(location: 0, length: length))
		foldableRanges.removeAll()

		for node in nodes {
			let range = backingRangeToDisplayRange(node.displayRange)

			// Attachables
			if let node = node as? Attachable, attachment = canvasDelegate?.textStorage(self, attachmentForAttachable: node) {
				// Use the attachment character
				replaceCharactersInRange(range, withString: String(Character(UnicodeScalar(NSAttachmentCharacter))))

				// Add the attributes
				addAttributes([
					NSAttachmentAttributeName: attachment
				], range: range)
				continue
			}

			// Apply attributes
			applyAttributes(node: node, currentFont: nil)
		}
	}

	public override func didUpdateDisplayText(displayText: String) {
		if !loaded {
			return
		}

		self.canvasDelegate?.textStorageWillUpdateNodes(self)
	}

	public override func didProcessBackingText(backingText: String) {
		if !loaded {
			return
		}

		let foldableRanges = self.foldableRanges
		for layoutManager in layoutManagers {
			if let layoutManager = layoutManager as? FoldingLayoutManager {

				// TODO: Hack to make this work. Not sure how to fix otherwise.
				dispatch_async(dispatch_get_main_queue()) {
					layoutManager.foldableRanges = foldableRanges
				}
			}
		}

		self.canvasDelegate?.textStorageDidUpdateNodes(self)
	}


	// MARK: - Accessing Nodes

	public func blockNodeAtBackingLocation(backingLocation: Int) -> BlockNode? {
		for node in nodes {
			var range = node.range
			range.length += 1

			if range.contains(backingLocation) {
				return node
			}
		}

		return nil
	}

	public func blockNodeAtDisplayLocation(displayLocation: Int) -> BlockNode? {
		for node in nodes {
			var range = backingRangeToDisplayRange(node.displayRange)
			range.length += 1

			if range.contains(displayLocation) {
				return node
			}
		}

		return nil
	}

	/// This returns all nodes that are contained in the backing range. Most consumers will filter the results. If a
	/// node is partially contained, it will be included in the results.
	public func nodesInBackingRange(backingRange: NSRange) -> [Node] {
		return nodesInBackingRange(backingRange, inNodes: nodes.map({ $0 as Node }))
	}

	private func nodesInBackingRange(backingRange: NSRange, inNodes nodes: [Node]) -> [Node] {
		var results = [Node]()

		for node in nodes {
			if node.range.intersection(backingRange) != nil {
				results.append(node)

				if let node = node as? NodeContainer {
					results += nodesInBackingRange(backingRange, inNodes: node.subnodes)
				}
			}
		}

		return results
	}


	// MARK: - Realtime

	public func connect(accessToken accessToken: String, organizationID: String, canvasID: String, realtimeURL: NSURL) {
		let controller = TransportController(serverURL: realtimeURL, accessToken: accessToken, organizationID: organizationID, canvasID: canvasID)
		controller.delegate = self
		webDelegate?.textStorage(self, willConnectWithWebView: controller.webView)
		transportController = controller
		controller.reload()
	}

	public func reconnect() {
		loaded = false
		transportController?.reload()
	}


	// MARK: - Private

	private func applyAttributes(node node: Node, currentFont: Font?) -> Font? {
		// Skip text nodes
		if node is Text {
			return nil
		}

		// Extend the range to include the trailing new line if present
		let range = backingRangeToDisplayRange(node.displayRange)

		// Normal elements
		let attributes = theme.attributesForNode(node, currentFont: currentFont)
		let font = attributes[NSFontAttributeName] as? Font
		addAttributes(attributes, range: range)

		// Foldable attributes
		if let node = node as? Foldable {
			foldableRanges += node.foldableRanges

			for folding in node.foldableRanges {
				let range = backingRangeToDisplayRange(folding)
				addAttributes(theme.foldingAttributes, range: range)
			}
		}

		if let node = node as? Link {
			// TODO: Derive from theme
			let color = Color(red: 0.420, green: 0.420, blue: 0.447, alpha: 1)
			addAttribute(NSForegroundColorAttributeName, value: color, range: backingRangeToDisplayRange(node.URLRange))

			if let title = node.title {
				addAttribute(NSForegroundColorAttributeName, value: color, range: backingRangeToDisplayRange(title.textRange))
			}
		}

		// Recurse
		if let node = node as? NodeContainer {
			let innerFont = font ?? currentFont
			for child in node.subnodes {
				applyAttributes(node: child, currentFont: innerFont)
			}
		}

		return font
	}

	private func adjustDisplaySelection(offset: Int) {
		guard var displaySelection = self.displaySelection else { return }

		displaySelection.location = min(length - displaySelection.length, max(0, displaySelection.location + offset))
		backingSelection = displayRangeToBackingRange(displaySelection)
	}

	private func markdownCompletion(displayRange: NSRange) {
		let text = string as NSString

		if displayRange.max > text.length {
			return
		}

		let searchRange = displayRange.union(text.lineRangeForRange(displayRange))

		text.enumerateSubstringsInRange(searchRange, options: .ByLines) { [weak self] string, range, enclosingRange, _ in
			guard let string = string,
				node = self?.blockNodeAtDisplayLocation(range.location),
				backingRange = self?.displayRangeToBackingRange(NSRange(location: range.location, length: displayRange.max - range.location + 1))
			where (string as NSString).length > 0
			else { return }

			var replacementRange = backingRange
			let replacement: String

			if let node = node as? UnorderedListItem {
				replacementRange = node.nativePrefixRange.union(backingRange)

				// Checklist item
				if string.hasPrefix("[] ") || string.hasPrefix("[ ] ") {
					replacement = ChecklistItem.nativeRepresentation(indentation: node.indentation, completion: .Incomplete)
				}

				// Completed checklist item
				else if string.hasPrefix("[x] ") {
					replacement = ChecklistItem.nativeRepresentation(indentation: node.indentation, completion: .Complete)
				} else {
					return
				}
			} else if node is Paragraph {
				// Unordered list
				if string.hasPrefix("- ") || string.hasPrefix("* ") {
					replacement = UnorderedListItem.nativeRepresentation(indentation: .Zero)
				}

				// Blockquote
				else if string.hasPrefix("> ") {
					replacement = Blockquote.nativeRepresentation()
				}

				// Checklist item
				else if string.hasPrefix("-[] ") || string.hasPrefix("-[ ] ") || string.hasPrefix("*[] ") || string.hasPrefix("*[ ] "){
					replacement = ChecklistItem.nativeRepresentation(indentation: .Zero, completion: .Incomplete)
				}

				// Completed checklist item
				else if string.hasPrefix("-[x] ") || string.hasPrefix("*[x] ") {
					replacement = ChecklistItem.nativeRepresentation(indentation: .Zero, completion: .Complete)
				}

				// Ordered list
				else {
					let scanner = NSScanner(string: string)
					if scanner.scanHexInt(nil) && scanner.scanString(". ", intoString: nil) {
						replacement = OrderedListItem.nativeRepresentation(indentation: .Zero)
					} else {
						return
					}
				}
			} else {
				return
			}

			self?.replaceBackingCharactersInRange(replacementRange, withString: replacement)
			self?.adjustDisplaySelection(-1)
		}
	}
}


extension CanvasTextStorage: TransportControllerDelegate {
	func transportController(controller: TransportController, didReceiveSnapshot content: String) {
		let connected = !loaded
		loaded = true
		backingText = content

		if connected {
			webDelegate?.textStorageDidConnect(self)
		}
	}

	func transportController(controller: TransportController, didReceiveOperation operation: Operation) {
		var backingText = self.backingText

		switch operation {
		case .Insert(let location, let string):
			if var backingSelection = self.backingSelection {
				// Shift selection
				let length = string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
				if Int(location) < backingSelection.location {
					backingSelection.location += string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
				}

				// Extend selection
				backingSelection.length += NSIntersectionRange(backingSelection, NSRange(location: location, length: length)).length
				self.backingSelection = backingSelection
			}

			// Update text
			let index = backingText.startIndex.advancedBy(Int(location))
			let range = index..<index
			backingText = backingText.stringByReplacingCharactersInRange(range, withString: string)
		case .Remove(let location, let length):
			if var backingSelection = self.backingSelection {
				// Shift selection
				if Int(location) < backingSelection.location {
					backingSelection.location -= Int(length)
				}

				// Extend selection
				backingSelection.length -= NSIntersectionRange(backingSelection, NSRange(location: location, length: length)).length
				self.backingSelection = backingSelection
			}

			// Update text
			let index = backingText.startIndex.advancedBy(Int(location))
			let range = index..<index.advancedBy(Int(length))
			backingText = backingText.stringByReplacingCharactersInRange(range, withString: "")
		}

		// Apply changes
		self.backingText = backingText
		self.backingSelection = backingSelection
	}

	func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		webDelegate?.textStorage(self, didReceiveWebErrorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber)
	}

	func transportController(controller: TransportController, didDisconnectWithErrorMessage errorMessage: String?) {
		webDelegate?.textStorage(self, didDisconnectWithErrorMessage: errorMessage)
	}
}
