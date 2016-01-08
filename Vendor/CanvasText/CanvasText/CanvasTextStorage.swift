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


public protocol CanvasTextStorageDelegate: class {
	func textStorageWillUpdateNodes(textStorage: CanvasTextStorage)
	func textStorageDidUpdateNodes(textStorage: CanvasTextStorage)
	func textStorage(textStorage: CanvasTextStorage, attachmentForAttachable node: Attachable) -> NSTextAttachment?
}


public class CanvasTextStorage: ShadowTextStorage {

	// MARK: - Properties

	public let theme: Theme

	public weak var canvasDelegate: CanvasTextStorageDelegate?

	private var transportController: TransportController?
	private var loaded = false

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
		if replacement == "\n", let node = firstBlockNodeInBackingRange(backingRange) where node.allowsReturnCompletion {
			// Bust out of completion
			if node.contentRange.length == 0 {
				backingRange = node.range
				replacement = ""
			} else {
				// Complete the node
				if let node = node as? NativeDelimitable {
					replacement += (backingText as NSString).substringWithRange(node.delimiterRange)
				}

				if let node = node as? Prefixable {
					replacement += (backingText as NSString).substringWithRange(node.prefixRange)
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

	public override func shadowsForBackingText(backingText: String) -> [Shadow] {
		if !loaded {
			return []
		}

		var shadows = [Shadow]()
		(nodes, shadows) = Parser(string: backingText).parse()
		
		return shadows
	}

	/// Optionally add attributes to the display version of the text.
	public override func attributedStringForDisplayText(displayText: String) -> NSAttributedString {
		let text = NSMutableAttributedString(string: displayText, attributes: theme.baseAttributes)

		if !loaded {
			return text
		}

		let count = nodes.count
		for (i, node) in nodes.enumerate() {
			let next: Node?
			if i < count - 1 {
				next = nodes[i + 1]
			} else {
				next = nil
			}

			let originalRange = backingRangeToDisplayRange(node.contentRange)
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

			// Normal elements
			let attributes = theme.attributesForNode(node, nextSibling: next, horizontalSizeClass: horizontalSizeClass)
			text.addAttributes(attributes, range: range)
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

		self.canvasDelegate?.textStorageDidUpdateNodes(self)
	}


	// MARK: - Accessing Nodes

	public func firstBlockNodeInBackingRange(backingRange: NSRange) -> BlockNode? {
		for node in nodes {
			var range = node.range
			range.length += 1

			if range.intersection(backingRange) != nil {
				return node
			}
		}

		return nil
	}


	// MARK: - Realtime

	public func connect(accessToken accessToken: String, organizationID: String, canvasID: String, realtimeURL: NSURL, setup: WKWebView -> Void) {
		let controller = TransportController(serverURL: realtimeURL, accessToken: accessToken, organizationID: organizationID, canvasID: canvasID)
		controller.delegate = self
		setup(controller.webView)
		transportController = controller
		controller.reload()
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
