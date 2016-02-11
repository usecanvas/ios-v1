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
	func textStorageDidUpdateSelection(textStorage: ShadowTextStorage)
}

/// Concrete text storage for using a backing string and a display string. This class also manages selection so when the
/// display or backing version of the text change, the selection is preserved.
public class ShadowTextStorage: NSTextStorage {

	// MARK: - Properties

	private let storage = NSMutableAttributedString()

	public var enabled = false

	public var backingText = "" {
		didSet {
			reprocess()
		}
	}

	public var backingSelection: NSRange? {
		didSet {
			updateSelection()
		}
	}

	public private(set) var displayText = ""

	public private(set) var displaySelection: NSRange? {
		didSet {
			selectionDelegate?.textStorageDidUpdateSelection(self)
		}
	}

	public private(set) var isProcessing = false

	/// Hidden regions from the backing text
	private private(set) var shadows = [NSRange]()

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

	public override var fixesAttributesLazily: Bool {
		return false
	}

	public override var string: String {
		return storage.string
	}

	public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
		return storage.attributesAtIndex(location, effectiveRange: range)
	}

	public override func replaceCharactersInRange(range: NSRange, withString str: String) {
		let displayRange = range
		let backingRange = displayRangeToBackingRange(displayRange)
		replaceBackingCharactersInRange(backingRange, withString: str)
	}

	public override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
		if range.max > (string as NSString).length {
			print("WARNING: Skipping applying invalid attribute.")
			return
		}
		storage.setAttributes(attrs, range: range)
	}

	public override func processEditing() {
		updateAttributes()
		super.processEditing()
		
		updateSelection()
		didProcessBackingText(backingText)
	}

	// MARK: - Manipulation

	public func replaceBackingCharactersInRange(backingRange: NSRange, withString str: String) {
		isProcessing = true
		backingText = (backingText as NSString).stringByReplacingCharactersInRange(backingRange, withString: str)

		// Update selection
		if var backingSelection = self.backingSelection {
			backingSelection.location += (str as NSString).length
			backingSelection.location -= backingRange.length
			self.backingSelection = backingSelection
		}

		isProcessing = false
	}


	// MARK: - Ranges

	public func backingRangeToDisplayRange(backingRange: NSRange) -> NSRange {
		var displayRange = backingRange

		for range in shadows {
			if range.location > backingRange.location {
				break
			}

			displayRange.location -= range.length
		}

		return displayRange
	}

	public func displayRangeToBackingRange(displayRange: NSRange) -> NSRange {
		var backingRange = displayRange

		for range in shadows {
			// Shadow starts after backing range
			if range.location > backingRange.location {

				// Shadow intersects. Expand lenght.
				if backingRange.intersection(range) > 0 {
					backingRange.length += range.length
					continue
				}

				// If the shadow starts directly after the backing range, expand to include it.
				if range.location == backingRange.max {
					backingRange.length += range.length
				}

				break
			}

			backingRange.location += range.length
		}

		return backingRange
	}


	// MARK: - Processing

	/// Calculate the hidden ranges for a given backing text.
	public func shadowsForBackingText(backingText: String) -> [NSRange] {
		return []
	}

	/// Optionally add attributes to the display version of the text.
	public func updateAttributes() {
		// Do nothing
	}

	public func didUpdateDisplayText(displayText: String) {
		// Do nothing
	}

	public func didProcessBackingText(backingText: String) {
		// Do nothing
	}

	public func reprocess() {
		guard enabled else { return }
		
		// Get hidden ranges
		shadows = shadowsForBackingText(backingText)

		// Calculate display text
		var displayText = backingText as NSString
		var offset = 0
		for r in shadows {
			var range = r
			range.location -= offset
			displayText = displayText.stringByReplacingCharactersInRange(range, withString: "")
			offset += range.length
		}
		self.displayText = displayText as String

		didUpdateDisplayText(self.displayText)

		// Update storage
		let range = NSRange(location: 0, length: storage.length)
		storage.replaceCharactersInRange(range, withString: self.displayText)
		edited([.EditedAttributes, .EditedCharacters], range: range, changeInLength: storage.length - range.length)
	}

	func willEndEditing() {}
	

	// MARK: - Private

	private func updateSelection() {
		guard let backingSelection = backingSelection else {
			displaySelection = nil
			return
		}

		let updatedDisplaySelection = backingRangeToDisplayRange(backingSelection)
		if updatedDisplaySelection != displaySelection {
			displaySelection = updatedDisplaySelection
		}
	}
}
