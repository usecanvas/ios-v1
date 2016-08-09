//
//  CanvasTextView.swift
//  Canvas
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasNative
import CanvasText

protocol CanvasTextViewFormattingDelegate: class {
	func textViewDidToggleBoldface(textView: CanvasTextView, sender: AnyObject?)
	func textViewDidToggleItalics(textView: CanvasTextView, sender: AnyObject?)
}

final class CanvasTextView: TextView {

	// MARK: - Properties

	weak var textController: TextController? {
		didSet {
			guard let theme = textController?.theme else { return }

			var attributes = theme.titleAttributes
			attributes[NSForegroundColorAttributeName] = theme.titlePlaceholderColor

			placeholderLabel.attributedText = NSAttributedString(
				string: LocalizedString.CanvasTitlePlaceholder.string,
				attributes: attributes
			)
		}
	}

	weak var formattingDelegate: CanvasTextViewFormattingDelegate?

	let dragGestureRecognizer: UIPanGestureRecognizer
	let dragThreshold: CGFloat = 60
	var dragContext: DragContext?

	let placeholderLabel: UILabel = {
		let label = UILabel()
		label.userInteractionEnabled = false
		label.hidden = true
		return label
	}()


	// MARK: - Initializers

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		dragGestureRecognizer = UIPanGestureRecognizer()

		super.init(frame: frame, textContainer: textContainer)

//		allowsEditingTextAttributes = true
		alwaysBounceVertical = true
		keyboardDismissMode = .Interactive
		backgroundColor = .clearColor()

		registerGestureRecognizers()

		managedSubviews.insert(placeholderLabel)
		addSubview(placeholderLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder
	
	override func toggleBoldface(sender: AnyObject?) {
		formattingDelegate?.textViewDidToggleBoldface(self, sender: sender)
	}

	override func toggleItalics(sender: AnyObject?) {
		formattingDelegate?.textViewDidToggleItalics(self, sender: sender)
	}

	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
		// Disable underline
		if action == #selector(toggleUnderline) {
			return false
		}

		return super.canPerformAction(action, withSender: sender)
	}


	// MARK: - UIView

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutPlaceholder()
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		textController?.setTintColor(tintColor)
	}


	// MARK: - Private

	private func layoutPlaceholder() {
		placeholderLabel.sizeToFit()

		var frame = placeholderLabel.frame
		frame.origin.x = textContainerInset.left
		frame.origin.y = textContainerInset.top
		placeholderLabel.frame = frame
	}
}


extension CanvasTextView: TextControllerAnnotationDelegate {
	func textController(textController: TextController, willAddAnnotation annotation: Annotation) {
		annotation.view.backgroundColor = .clearColor()
		managedSubviews.insert(annotation.view)
		insertSubview(annotation.view, atIndex: 0)
	}

	func textController(textController: TextController, willRemoveAnnotation annotation: Annotation) {
		managedSubviews.remove(annotation.view)
	}
}
