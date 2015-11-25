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

public protocol TextStorageSelectionDelegate: class {
	func textStorageDidUpdateSelection(textStorage: TextStorage)
}


public protocol TextStorageNodesDelegate: class {
	func textStorageDidUpdateNodes(textStorage: TextStorage)
}


public class TextStorage: NSTextStorage {

	// MARK: - Properties

	public let theme: Theme

	private let storage = NSMutableAttributedString()

	public var backingText = "" {
		didSet {
			backingTextDidChange()
		}
	}

	public var backingSelection: NSRange = .zero {
		didSet {
			displaySelection = backingRangeToDisplayRange(backingSelection)
			selectionDelegate?.textStorageDidUpdateSelection(self)
		}
	}

	public private(set) var displayText = ""

	public private(set) var displaySelection: NSRange = .zero

	public private(set) var nodes = [Node]()
	private var hidden = [NSRange]()

	public weak var selectionDelegate: TextStorageSelectionDelegate?
	public weak var nodesDelegate: TextStorageNodesDelegate?

	private var transportController: TransportController?

	private var ignoreChange = false


	// MARK: - Initializers

	public init(theme: Theme) {
		self.theme = theme
		super.init()
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

	public override var string: String {
		return storage.string
	}

	public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
		return storage.attributesAtIndex(location, effectiveRange: range)
	}

	public override func replaceCharactersInRange(range: NSRange, withString str: String) {
		// Update the backing text
		let text = backingText as NSString
		backingText = text.stringByReplacingCharactersInRange(displayRangeToBackingRange(range), withString: str) as String

		// Submit the transport operation
		change(range: range, replacementText: str)
	}

	public override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
		storage.setAttributes(attrs, range: range)
	}


	// MARK: - Realtime

	public func connect(accessToken accessToken: String, collectionID: String, canvasID: String, setup: WKWebView -> Void) {
		let controller = TransportController(serverURL: NSURL(string: "wss://api.usecanvas.com/realtime")!, accessToken: accessToken, collectionID: collectionID, canvasID: canvasID)
		controller.delegate = self
		setup(controller.webView)
		transportController = controller
		controller.reload()
	}


	// MARK: - Ranges

	public func backingRangeToDisplayRange(backingRange: NSRange) -> NSRange {
		var displayRange = backingRange

		for range in hidden {
			if range.location > backingRange.location {
				break
			}

			displayRange.location -= range.length
		}

		return displayRange
	}

	public func displayRangeToBackingRange(displayRange: NSRange) -> NSRange {
		var backingRange = displayRange

		for range in hidden {
			if range.location > backingRange.location {
				break
			}

			backingRange.location += range.length
		}

		return backingRange
	}


	// MARK: - Private

	private func change(range range: NSRange, replacementText text: String) {
		guard let transportController = transportController else {
			print("[CanvasText.TextStorage] Tried to submit operation without transport controller.")
			return
		}

		let backingRange = displayRangeToBackingRange(range)

		// Insert
		if range.length == 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: text))
		}

		// Remove
		else {
			transportController.submitOperation(.Remove(location: UInt(backingRange.location), length: UInt(backingRange.length)))
		}
	}

	private func backingTextDidChange() {
		if ignoreChange {
			return
		}

		// Convert to Foundation string so we can work with `NSRange` instead of `Range` since the TextKit APIs take
		// `NSRange` instead `Range`. Bummer.
		let text = backingText as NSString

		// We're going to rebuild `nodes` and `displayText` from the new `backingText`.
		var nodes = [Node]()
		var hidden = [NSRange]()

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
					hidden.append(node.delimiterRange)
				}

				if let node = node as? Prefixable {
					hidden.append(node.prefixRange)
				}

				nodes.append(node)
				return
			}

			// Unsupported range
			var range = substringRange
			range.length += 1 // Account for new line
			hidden.append(range)
		}

		self.nodes = nodes
		self.hidden = hidden
		displayText = nodes.flatMap { $0.contentInString(backingText) }.joinWithSeparator("\n")

		beginEditing()
		let range = NSRange(location: 0, length: storage.length)
		storage.replaceCharactersInRange(range, withAttributedString: NSAttributedString(string: displayText, attributes: theme.baseAttributes))

		let count = nodes.count
		for (i, node) in nodes.enumerate() {
			let next: Node?
			if i < count - 1 {
				next = nodes[i + 1]
			} else {
				next = nil
			}

			let attributes = theme.attributesForNode(node, nextSibling: next)
			let range = backingRangeToDisplayRange(node.contentRange)
			addAttributes(attributes, range: range)
		}

		endEditing()

		edited([.EditedAttributes, .EditedCharacters], range: range, changeInLength: storage.length - range.length)

		nodesDelegate?.textStorageDidUpdateNodes(self)
	}
}


extension TextStorage: TransportControllerDelegate {
	func transportController(controller: TransportController, didReceiveSnapshot text: String) {
		backingText = text
	}

	func transportController(controller: TransportController, didReceiveOperation operation: Operation) {
		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			guard let this = self else { return }
			var backingText = this.backingText
			var backingSelection = this.backingSelection

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
			this.backingText = backingText
			this.backingSelection = backingSelection
		}
	}
}
