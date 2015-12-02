//
//  TextView.swift
//  Canvas
//
//  Created by Sam Soffes on 12/1/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

/// Custom text view to ensure the insertion point doesn't fill the margin of a paragraph. This is terrible.
class TextView: UITextView {

	// MARK: - Properties

	private var customInsertionPointView: UIView?

	private var insertionPointView: UIView? {
		willSet {
			guard let insertionPointView = insertionPointView else { return }
			insertionPointView.removeObserver(self, forKeyPath: "frame")
			insertionPointView.removeObserver(self, forKeyPath: "alpha")
		}

		didSet {
			guard let insertionPointView = insertionPointView else { return }
			insertionPointView.hidden = true
			insertionPointView.addObserver(self, forKeyPath: "frame", options: [.New], context: nil)
			insertionPointView.addObserver(self, forKeyPath: "alpha", options: [.New], context: nil)

			let custom = UIView()
			custom.backgroundColor = tintColor
			insertionPointView.superview?.addSubview(custom)
			customInsertionPointView = custom
		}
	}


	// MARK: - Initializers

	deinit {
		guard let insertionPointView = insertionPointView else { return }
		insertionPointView.removeObserver(self, forKeyPath: "frame")
		insertionPointView.removeObserver(self, forKeyPath: "alpha")
	}


	// MARK: - Hijacking

	func hijack() {
		guard window != nil && insertionPointView == nil else { return }
		insertionPointView = cursorView()
	}


	// MARK: - Private

	/// Find the text container view
	private func findTextContainerView() -> UIView? {
		for view in subviews {
			if view.dynamicType.description() == "_UITextContainerView" {
				return view
			}
		}
		return nil
	}

	/// Find the selection view in the text container view
	private func findTextSelectionView(textContainerView: UIView) -> UIView? {
		for view in textContainerView.subviews {
			if view.dynamicType.description() == "UITextSelectionView" {
				return view
			}
		}

		return nil
	}

	func cursorView() -> UIView? {
		guard let containerView = findTextContainerView(),
			selectionView = findTextSelectionView(containerView)
		else { return nil }

		return selectionView.subviews.first
	}


	// MARK: - NSKeyValueObserving

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		guard let view = object as? UIView where view == insertionPointView else {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
			return
		}

		if keyPath == "frame", let value = change?[NSKeyValueChangeNewKey] as? NSValue {
			var frame = value.CGRectValue()
			
			// TODO: Get this value from the font
			frame.size.height = min(24.4125, frame.size.height)
			customInsertionPointView?.frame = frame
			return
		}

		if keyPath == "alpha", let value = change?[NSKeyValueChangeNewKey] as? CGFloat {
			UIView.animateWithDuration(1.43, delay: 0, options: [], animations: { [weak self] in
				self?.customInsertionPointView?.alpha = value
			}, completion: nil)
		}
	}
}
