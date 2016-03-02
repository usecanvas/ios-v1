//
//  TextView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import CanvasKit
import CanvasText
import CanvasNative

class CanvasTextView: UITextView {

	// MARK: - Properties

	var annotations = [UIView]()
	var lineNumber: UInt = 1

	let iconView = UIImageView()
	let placeholderLabel = UILabel()

	var updatingFolding = false

	let indentGestureRecognizer: UIGestureRecognizer = {
		let gesture = UISwipeGestureRecognizer()
		gesture.numberOfTouchesRequired = 1
		gesture.direction = .Right
		return gesture
	}()

	let outdentGestureRecognizer: UIGestureRecognizer = {
		let gesture = UISwipeGestureRecognizer()
		gesture.numberOfTouchesRequired = 1
		gesture.direction = .Left
		return gesture
	}()


	// MARK: - Initializers {

	init(textStorage: NSTextStorage) {
		let layoutManager = FoldingLayoutManager()
		layoutManager.allowsNonContiguousLayout = false

		let container = CanvasTextContainer()
		container.lineFragmentPadding = 0
		container.widthTracksTextView = true
		layoutManager.addTextContainer(container)
		
		textStorage.addLayoutManager(layoutManager)

		super.init(frame: .zero, textContainer: container)

		layoutManager.layoutDelegate = self

		alwaysBounceVertical = true
		keyboardDismissMode = .Interactive
		editable = false

		iconView.image = UIImage(named: "description")
		addSubview(iconView)

		if let textStorage = textStorage as? CanvasTextStorage {
			textStorage.canvasDelegate = self

			let theme = textStorage.theme
			font = theme.fontOfSize(theme.fontSize)

			var attributes = theme.titleAttributes
			typingAttributes = attributes

			attributes[NSForegroundColorAttributeName] = theme.placeholderColor

			placeholderLabel.attributedText = NSAttributedString(
				string: LocalizedString.Loading.string,
				attributes: attributes
			)

			iconView.tintColor = theme.placeholderColor
		}

		registerGestureRecognizers()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView
	
	override func traitCollectionDidChange(previousTraitOrganization: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitOrganization)

		guard let textStorage = textStorage as? CanvasTextStorage else { return }
		textStorage.horizontalSizeClass = traitCollection.horizontalSizeClass
		textStorage.reprocess()
	}

	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		// I can't believe I have to do this… *sigh*
		for view in annotations {
			if view.userInteractionEnabled && view.frame.contains(point) {
				return view
			}
		}

		return super.hitTest(point, withEvent: event)
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()

		guard let textStorage = textStorage as? CanvasTextStorage else { return }
		textStorage.theme.tintColor = tintColor
	}


	// MARK: - UITextInput

	// Only display the caret in the used rect (if available).
	override func caretRectForPosition(position: UITextPosition) -> CGRect {
		var rect = super.caretRectForPosition(position)

		if let layoutManager = textContainer.layoutManager {
			layoutManager.ensureLayoutForTextContainer(textContainer)

			let characterIndex = offsetFromPosition(beginningOfDocument, toPosition: position)

			let height: CGFloat

			if characterIndex == 0 {
				// Hack for empty document
				height = 43.82015625
			} else {
				if characterIndex == textStorage.length {
					return rect
				}

				let glyphIndex = layoutManager.glyphIndexForCharacterAtIndex(characterIndex)

				if UInt(glyphIndex) == UInt.max - 1 {
					return rect
				}

				height = layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, effectiveRange: nil).size.height
			}

			if height > 0 {
				rect.size.height = height
			}
		}

		return rect
	}

	// Omit empty width rect when drawing selection rects.
	override func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
		let selectionRects = super.selectionRectsForRange(range)
		return selectionRects.filter({ selection in
			guard let selection = selection as? UITextSelectionRect else { return false }
			return selection.rect.size.width > 0
		})
	}


	// MARK: - Actions

	func toggleCheckbox(sender: CheckboxView?) {
		guard let node = sender?.checklist, textStorage = textStorage as? CanvasTextStorage else { return }

		let string = node.completion.opposite.string
		textStorage.replaceBackingCharactersInRange(node.completedRange, withString: string)
	}


	// MARK: - Internal

	func nodeAtPoint(point: CGPoint) -> Node? {
		guard let textRange = characterRangeAtPoint(point),
			textStorage = textStorage as? CanvasTextStorage
			else { return nil }

		let range = NSRange(
			location: offsetFromPosition(beginningOfDocument, toPosition: textRange.start),
			length: offsetFromPosition(textRange.start, toPosition: textRange.end)
		)

		return textStorage.blockNodeAtBackingLocation(textStorage.displayRangeToBackingRange(range).location)
	}

	func firstRectForBackingRange(backingRange: NSRange) -> CGRect? {
		guard let textStorage = textStorage as? CanvasTextStorage else { return nil }
		return firstRectForDisplayRange(textStorage.backingRangeToDisplayRange(backingRange))
	}

	func firstRectForDisplayRange(displayRange: NSRange) -> CGRect? {
		guard let start = positionFromPosition(beginningOfDocument, offset: displayRange.location),
			end = positionFromPosition(start, offset: displayRange.length),
			textRange = textRangeFromPosition(start, toPosition: end)
		else { return nil }

		return firstRectForRange(textRange)
	}

	func firstRectForNode(node: Node) -> CGRect? {
		return firstRectForBackingRange(node.displayRange)
	}

	func lastRectForNode(node: Node) -> CGRect? {
		return lastRectForBackingRange(node.displayRange)
	}

	func lastRectForDisplayRange(displayRange: NSRange) -> CGRect? {
		guard let start = positionFromPosition(beginningOfDocument, offset: displayRange.location),
			end = positionFromPosition(start, offset: displayRange.length),
			textRange = textRangeFromPosition(start, toPosition: end)
		else { return nil }

		let rects = selectionRectsForRange(textRange)
			.flatMap { ($0 as? UITextSelectionRect)?.rect }
			.filter { $0.width > 0 }

		return rects.last
	}

	func lastRectForBackingRange(backingRange: NSRange) -> CGRect? {
		guard let textStorage = textStorage as? CanvasTextStorage else { return nil }
		return lastRectForDisplayRange(textStorage.backingRangeToDisplayRange(backingRange))
	}


	// MARK: - Private

	private func didUpdateNodes() {
		editable = true

		let attributes = placeholderLabel.attributedText?.attributesAtIndex(0, effectiveRange: nil)
		placeholderLabel.attributedText = NSAttributedString(
			string: LocalizedString.CanvasTitlePlaceholder.string,
			attributes: attributes
		)

		// TODO: This is fragile
		if text == "\n" {
			becomeFirstResponder()
			selectedRange = .zero
		}

		dispatch_async(dispatch_get_main_queue()) {
			self.updateAnnotations()
			self.updateTypingAttributes()
		}
	}

	// TODO: Don't special case Title
	private func updateTypingAttributes() {
		guard let textStorage = textStorage as? CanvasTextStorage else { return }

		// Set the typing attributes for the current node if there is one
		if let node = textStorage.blockNodeAtBackingLocation(textStorage.displayRangeToBackingRange(selectedRange).location) {
			typingAttributes = textStorage.theme.attributesForNode(node, currentFont: nil)
			return
		}

		// Title attributes if in the first line
		if textStorage.string.isEmpty {
			typingAttributes = textStorage.theme.titleAttributes
			return
		}

		// Title attributes if the range is on the first line
		let string = textStorage.string as NSString
		var shouldReturn = false
		string.enumerateSubstringsInRange(NSRange(location: 0, length: selectedRange.max), options: [.ByLines]) { _, range, _, stop in
			if self.selectedRange.location <= range.max {
				self.typingAttributes = textStorage.theme.titleAttributes
				shouldReturn = true
			}
			stop.memory = true
		}

		if shouldReturn {
			return
		}

		// Fallback to base attributes
		typingAttributes = textStorage.theme.baseAttributes
	}
}


extension CanvasTextView: CanvasTextStorageDelegate {
	func textStorageWillUpdateNodes(textStorage: CanvasTextStorage) {
		removeAnnotations()
	}
	
	func textStorageDidUpdateNodes(textStorage: CanvasTextStorage) {
		setNeedsDisplay()
		didUpdateNodes()
	}

	func textStorage(textStorage: CanvasTextStorage, attachmentForAttachable node: Attachable) -> NSTextAttachment? {
		guard let node = node as? Image, scale = window?.screen.scale else { return nil }
		let attachment = NSTextAttachment()

		let width = textContainer.size.width - (textContainer.lineFragmentPadding * 2)

		var size = node.size ?? CGSize(width: floor(width), height: 300)
		let image = ImagesController.sharedController.fetchImage(node: node, size: size, scale: scale) { [weak self] node, image in
			guard let image = image,
				textStorage = self?.textStorage as? CanvasTextStorage
			else { return }

			let range = textStorage.backingRangeToDisplayRange(node.displayRange)
			var attributes = textStorage.attributesAtIndex(range.location, effectiveRange: nil)

			let size = image.size
			let updatedAttachment = NSTextAttachment()
			updatedAttachment.bounds = CGRect(x: 0, y: 0, width: width, height: width * size.height / size.width)
			updatedAttachment.image = image
			attributes[NSAttachmentAttributeName] = updatedAttachment

			textStorage.setAttributes(attributes, range: range)
			textStorage.edited([.EditedAttributes], range: range, changeInLength: 0)
		}

		attachment.image = image

		size = image?.size ?? CGSize(width: floor(width), height: 300)
		attachment.bounds = CGRect(x: 0, y: 0, width: width, height: width * size.height / size.width).ceil

		return attachment
	}
}
