//
//  StackViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

class StackViewController: UIViewController {
	
	// MARK: - Properties
	
	let stackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .Vertical
		view.alignment = .Fill
		return view
	}()
	
	private var centerYConstraint: NSLayoutConstraint? {
		willSet {
			guard let old = centerYConstraint else { return }
			NSLayoutConstraint.deactivateConstraints([old])
		}
		
		didSet {
			guard let new = centerYConstraint else { return }
			NSLayoutConstraint.activateConstraints([new])
		}
	}
	
	private var keyboardFrame: CGRect? {
		didSet {
			keyboardFrameDidChange()
		}
	}
	
	private var visible = false
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		view.addSubview(stackView)
		
		let width = stackView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 0.8)
		width.priority = UILayoutPriorityDefaultHigh
		
		let top = stackView.topAnchor.constraintGreaterThanOrEqualToAnchor(view.topAnchor, constant: 64)
		top.priority = UILayoutPriorityDefaultLow
		
		NSLayoutConstraint.activateConstraints([
			stackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			top,
			width,
			stackView.widthAnchor.constraintLessThanOrEqualToConstant(400)
		])
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
		keyboardFrameDidChange()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.visible = true
		}
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		visible = false
	}

	
	// MARK: - Private
	
	@objc private func keyboardWillChangeFrame(notification: NSNotification) {
		guard let dictionary = notification.userInfo as? [String: AnyObject],
			duration = dictionary[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,
			curve = (dictionary[UIKeyboardAnimationCurveUserInfoKey] as? Int).flatMap(UIViewAnimationCurve.init),
			rect = (dictionary[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
			else { return }
		
		let frame = view.convertRect(rect, fromView: nil)
		
		let change = { [weak self] in
			self?.keyboardFrame = frame
			self?.view.layoutIfNeeded()
		}
		
		if visible {
			UIView.beginAnimations(nil, context: nil)
			UIView.setAnimationDuration(duration)
			UIView.setAnimationCurve(curve)
			change()
			UIView.commitAnimations()
		} else {
			UIView.performWithoutAnimation(change)
		}
	}
	
	private func keyboardFrameDidChange() {
		guard let keyboardFrame = keyboardFrame else {
			centerYConstraint = stackView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
			return
		}
		
		var rect = view.bounds
		rect.size.height -= rect.intersect(keyboardFrame).height
		rect.origin.y += UIApplication.sharedApplication().statusBarFrame.size.height
		rect.size.height -= UIApplication.sharedApplication().statusBarFrame.size.height
		
		let contstraint = stackView.centerYAnchor.constraintEqualToAnchor(view.topAnchor, constant: rect.midY)
		contstraint.priority = UILayoutPriorityDefaultHigh
		
		centerYConstraint = contstraint
	}
}
