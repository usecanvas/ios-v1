//
//  ShadowTextStorage.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/24/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

public protocol ShadowTextStorageSelectionDelegate: class {
	func shadowTextStorageDidUpdateSelection(textStorage: ShadowTextStorage)
}

/// Concrete text storage for using a backing string and a display string. This class also manages selection so when the
/// display or backing version of the text change, the selection is preserved.
public class ShadowTextStorage: NSTextStorage {

	// MARK: - Properties

	private let storage = NSMutableAttributedString()

	public var backingText = "" {
		didSet {
			reprocess()
		}
	}

	public var backingSelection: NSRange = .zero {
		didSet {
			updateSelection()
		}
	}

	public private(set) var displayText = ""

	public private(set) var displaySelection: NSRange = .zero {
		didSet {
			selectionDelegate?.shadowTextStorageDidUpdateSelection(self)
		}
	}

	private private(set) var hiddenRanges = [NSRange]()

	public weak var selectionDelegate: ShadowTextStorageSelectionDelegate?


	// MARK: - Initializers

	public init(backingText: String) {
		super.init()
		self.backingText = backingText
		reprocess()
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
		let text = backingText as NSString
		backingText = text.stringByReplacingCharactersInRange(displayRangeToBackingRange(range), withString: str) as String
	}

	public override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
		storage.setAttributes(attrs, range: range)
	}


	// MARK: - Ranges

	public func backingRangeToDisplayRange(backingRange: NSRange) -> NSRange {
		var displayRange = backingRange

		for range in hiddenRanges {
			if range.location > backingRange.location {
				break
			}

			displayRange.location -= range.length
		}

		return displayRange
	}

	public func displayRangeToBackingRange(displayRange: NSRange) -> NSRange {
		var backingRange = displayRange

		for range in hiddenRanges {
			if range.location > backingRange.location {
				break
			}

			backingRange.location += range.length
		}

		return backingRange
	}


	// MARK: - Processing

	/// Calculate the hidden ranges for a given backing text.
	public func hiddenRangesForBackingText(backingText: String) -> [NSRange] {
		return []
	}

	/// Optionally add attributes to the display version of the text.
	public func attributedStringForDisplayText(displayText: String) -> NSAttributedString {
		return NSAttributedString(string: displayText)
	}

	public func didProcessBackingText(backingText: String) {
		// Do nothing
	}

	public func reprocess() {
		// Get hidden ranges
		hiddenRanges = hiddenRangesForBackingText(backingText)

		// Calculate display text
		var displayText = backingText as NSString
		var offset = 0
		for r in hiddenRanges {
			var range = r
			range.location -= offset
			displayText = displayText.stringByReplacingCharactersInRange(range, withString: "")
			offset += range.length
		}
		self.displayText = displayText as String

		// Update storage
		beginEditing()

		let range = NSRange(location: 0, length: storage.length)
		let string = attributedStringForDisplayText(self.displayText)

		storage.replaceCharactersInRange(range, withAttributedString: string)

		endEditing()

		edited([.EditedAttributes, .EditedCharacters], range: range, changeInLength: storage.length - range.length)

		updateSelection()
		
		didProcessBackingText(backingText)
	}


	// MARK: - Private

	private func updateSelection() {
		let updatedDisplaySelection = backingRangeToDisplayRange(backingSelection)
		if updatedDisplaySelection != displaySelection {
			displaySelection = updatedDisplaySelection
		}
	}
}
