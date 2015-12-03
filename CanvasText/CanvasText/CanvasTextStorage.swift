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
	func textStorageDidUpdateNodes(textStorage: CanvasTextStorage)
	func textStorage(textStorage: CanvasTextStorage, attachmentForAttachable node: Attachable) -> NSTextAttachment?
}


public class CanvasTextStorage: ShadowTextStorage {

	// MARK: - Properties

	public let theme: Theme

	public weak var canvasDelegate: CanvasTextStorageDelegate?

	private var transportController: TransportController?

	public private(set) var nodes = [Node]()

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
		super.replaceCharactersInRange(range, withString: str)

		// Submit the transport operation
		guard let transportController = transportController else {
			print("[CanvasText.TextStorage] Tried to submit operation without transport controller.")
			return
		}

		let backingRange = displayRangeToBackingRange(range)

		// Insert
		if range.length == 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: str))
			return
		}

		// Remove
		transportController.submitOperation(.Remove(location: UInt(backingRange.location), length: UInt(backingRange.length)))

		// Insert after removing
		if range.length > 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: str))
		}
	}


	// MARK: - ShadowTextStorage

	public override func hiddenRangesForBackingText(backingText: String) -> [NSRange] {
		// Convert to Foundation string so we can work with `NSRange` instead of `Range` since the TextKit APIs take
		// `NSRange` instead `Range`. Bummer.
		let text = backingText as NSString

		// We're going to rebuild `nodes` and `displayText` from the new `backingText`.
		var nodes = [Node]()
		var hiddenRanges = [NSRange]()

		// Enumerate the string blocks of the `backingText`.
		text.enumerateSubstringsInRange(NSRange(location: 0, length: text.length), options: [.ByLines]) { substring, substringRange, _, _ in
			// Ensure we have a substring to work with
			guard let substring = substring else { return }

			// Setup a scanner
			let scanner = NSScanner(string: substring)
			scanner.charactersToBeSkipped = nil

			for type in nodeParseOrder {
				guard let node = type.init(string: substring, enclosingRange: substringRange) else { continue }

				if let node = node as? Delimitable {
					hiddenRanges.append(node.delimiterRange)
				}

				if let node = node as? Prefixable {
					hiddenRanges.append(node.prefixRange)
				}

				nodes.append(node)
				return
			}

			// Unsupported range
			var range = substringRange

			// Account for new line
			if range.max + 1 < text.length {
				range.length += 1
			}
			
			hiddenRanges.append(range)
		}

		self.nodes = nodes

		return hiddenRanges
	}

	/// Optionally add attributes to the display version of the text.
	public override func attributedStringForDisplayText(displayText: String) -> NSAttributedString {
		let text = NSMutableAttributedString(string: displayText, attributes: theme.baseAttributes)

		let count = nodes.count
		for (i, node) in nodes.enumerate() {
			let next: Node?
			if i < count - 1 {
				next = nodes[i + 1]
			} else {
				next = nil
			}

			let range = backingRangeToDisplayRange(node.contentRange)

			// TODO: This is to support blank lines. Currently causes some issues
//			if next != nil {
//				range.length += 1
//			}

			// Attachables
			if let node = node as? Attachable, attachment = canvasDelegate?.textStorage(self, attachmentForAttachable: node) {
				// Use the attachment character
				text.replaceCharactersInRange(range, withString: String(Character(UnicodeScalar(NSAttachmentCharacter))))

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

	public override func didProcessBackingText(backingText: String) {
		self.canvasDelegate?.textStorageDidUpdateNodes(self)
	}


	// MARK: - Realtime

	public func connect(accessToken accessToken: String, collectionID: String, canvasID: String, realtimeURL: NSURL, setup: WKWebView -> Void) {
		let controller = TransportController(serverURL: realtimeURL, accessToken: accessToken, collectionID: collectionID, canvasID: canvasID)
		controller.delegate = self
		setup(controller.webView)
		transportController = controller
		controller.reload()
	}
}


extension CanvasTextStorage: TransportControllerDelegate {
	func transportController(controller: TransportController, didReceiveSnapshot text: String) {
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
