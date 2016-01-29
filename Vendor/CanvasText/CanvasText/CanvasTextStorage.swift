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

	func textStorage(textStorage: CanvasTextStorage, willConnectWithWebView webView: WKWebView)
	func textStorage(textStorage: CanvasTextStorage, didReceiveWebErrorMessage errorMessage: String, lineNumber: UInt?, columnNumber: UInt?)
}


public class CanvasTextStorage: ShadowTextStorage {

	// MARK: - Properties

	public var theme: Theme {
		didSet {
			reprocess()
		}
	}

	public weak var canvasDelegate: CanvasTextStorageDelegate?

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

		if str.isEmpty {
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
	}


	// MARK: - ShadowTextStorage

	override public func replaceBackingCharactersInRange(range: NSRange, withString str: String) {
		var backingRange = range
		var replacement = str

		// Return completion
		if replacement == "\n", let node = blockNodeAtBackingLocation(backingRange.location) where node.allowsReturnCompletion {
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

		// Replace backing text
		super.replaceBackingCharactersInRange(backingRange, withString: replacement)

		// Update the selection if we messed with things
		if backingRange != range || replacement != str {
			backingSelection = NSRange(location: backingRange.max, length: 0)
		}

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
	public override func attributedStringForDisplayText(displayText: String) -> NSAttributedString {
		let text = NSMutableAttributedString(string: displayText, attributes: theme.baseAttributes)

		if !loaded {
			return text
		}

		foldableRanges.removeAll()

		let count = nodes.count
		for (i, node) in nodes.enumerate() {
			let next: Node?
			if i < count - 1 {
				next = nodes[i + 1]
			} else {
				next = nil
			}

			let originalRange = backingRangeToDisplayRange(node.displayRange)
			var range = originalRange

			// Extend the range to include the trailing new line if present
			if next != nil && range.max < text.length {
				range.length += 1
			}

			// Attachables
			if let node = node as? Attachable, attachment = canvasDelegate?.textStorage(self, attachmentForAttachable: node) {
				// Use the attachment character
				text.replaceCharactersInRange(originalRange, withString: String(Character(UnicodeScalar(NSAttachmentCharacter))))

				// Add space after the attachment
				let paragraph = NSMutableParagraphStyle()
				paragraph.paragraphSpacing = theme.paragraphSpacing

				// Add the attributes
				text.addAttributes([
					NSParagraphStyleAttributeName: paragraph,
					NSAttachmentAttributeName: attachment
				], range: range)
				continue
			}

			// Apply attributes
			applyAttributes(text: text, node: node, nextSibling: next)
		}

		return text
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

		for layoutManager in layoutManagers {
			if let layoutManager = layoutManager as? FoldingLayoutManager {
				layoutManager.foldableRanges = foldableRanges
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
		canvasDelegate?.textStorage(self, willConnectWithWebView: controller.webView)
		transportController = controller
		controller.reload()
	}


	// MARK: - Private

	private func applyAttributes(text text: NSMutableAttributedString, node: Node, nextSibling: Node? = nil) {
		// Skip text nodes
		if node is Text {
			return
		}

		// Extend the range to include the trailing new line if present
		let originalRange = backingRangeToDisplayRange(node.displayRange)
		var range = originalRange
		if nextSibling != nil && range.max < text.length {
			range.length += 1
		}

		// Normal elements
		let attributes = theme.attributesForNode(node, nextSibling: nextSibling, horizontalSizeClass: horizontalSizeClass)
		text.addAttributes(attributes, range: range)

		// Foldable attributes
		if let node = node as? Foldable {
			foldableRanges += node.foldableRanges

			for folding in node.foldableRanges {
				let range = backingRangeToDisplayRange(folding)
				text.addAttributes(theme.foldingAttributes, range: range)
			}
		}

		if let node = node as? Link {
			// TODO: Derive from theme
			let color = Color(red: 0.420, green: 0.420, blue: 0.447, alpha: 1)

			text.addAttribute(NSForegroundColorAttributeName, value: color, range: backingRangeToDisplayRange(node.URLRange))

			if let title = node.title {
				text.addAttribute(NSForegroundColorAttributeName, value: color, range: backingRangeToDisplayRange(title.textRange))
			}
		}

		// Recurse
		if let node = node as? NodeContainer {
			for child in node.subnodes {
				applyAttributes(text: text, node: child)
			}
		}
	}
}


extension CanvasTextStorage: TransportControllerDelegate {
	func transportController(controller: TransportController, didReceiveSnapshot text: String) {
		loaded = true
		backingText = text
	}

	func transportController(controller: TransportController, didReceiveOperation operation: Operation) {
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
			let range = index..<index
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
			let range = index..<index.advancedBy(Int(length))
			backingText = backingText.stringByReplacingCharactersInRange(range, withString: "")
		}

		// Apply changes
		self.backingText = backingText
		self.backingSelection = backingSelection
	}

	func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String, lineNumber: UInt?, columnNumber: UInt?) {
		canvasDelegate?.textStorage(self, didReceiveWebErrorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber)
	}
}
