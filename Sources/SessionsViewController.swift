//
//  SessionsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/16/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import GradientView

class SessionsViewController: UIViewController {

	// MARK: - Properties

	let backgroundView: GradientView = {
		let view = GradientView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.colors = [
			Color.brand,
			UIColor(red: 0.400, green: 0, blue: 1, alpha: 1)
		]
		view.automaticallyDims = false
		return view
	}()

	let illustrationView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor(patternImage: UIImage(named: "Illustration")!)
		view.alpha = 0.07
		return view
	}()

	let stackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .Vertical
		view.spacing = 16
		view.alignment = .Center
		return view
	}()

	let passwordContainer: TextFieldContainer = {
		let container = TextFieldContainer(textField: LoginTextField())
		container.translatesAutoresizingMaskIntoConstraints = false
		container.textField.secureTextEntry = true
		container.textField.placeholder = LocalizedString.PasswordPlaceholder.string
		container.textField.returnKeyType = .Go

		container.visualEffectView.layer.cornerRadius = container.textField.layer.cornerRadius
		container.visualEffectView.layer.masksToBounds = true
		return container
	}()

	let submitButton: IndicatorButton = {
		let button = IndicatorButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitleColor(UIColor(red: 0.209, green: 0.556, blue: 1, alpha: 1), forState: .Disabled)
		return button
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
			guard let keyboardFrame = keyboardFrame else {
				centerYConstraint = nil
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

	var textFields: [UITextField] {
		return [passwordContainer.textField]
	}

	var loading = false {
		didSet {
			textFields.forEach { $0.enabled = !loading }
			submitButton.enabled = !loading
			submitButton.loading = loading
			UIApplication.sharedApplication().networkActivityIndicatorVisible = loading
		}
	}

	private var visible = false


	// MARK: - Initializers

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)

		view.backgroundColor = Color.brand
		view.addSubview(backgroundView)
		view.addSubview(illustrationView)

		textFields.forEach { $0.delegate = self }

		submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)

		view.addSubview(stackView)

		let width = stackView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 0.8)
		width.priority = UILayoutPriorityDefaultHigh

		let top = stackView.topAnchor.constraintGreaterThanOrEqualToAnchor(view.topAnchor, constant: 64)
		top.priority = UILayoutPriorityDefaultLow

		NSLayoutConstraint.activateConstraints([
			backgroundView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			backgroundView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			backgroundView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			backgroundView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),

			illustrationView.leadingAnchor.constraintEqualToAnchor(backgroundView.leadingAnchor),
			illustrationView.trailingAnchor.constraintEqualToAnchor(backgroundView.trailingAnchor),
			illustrationView.topAnchor.constraintEqualToAnchor(backgroundView.topAnchor),
			illustrationView.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor),

			stackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			top,
			width,
			stackView.widthAnchor.constraintLessThanOrEqualToConstant(400)
		])
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		textFields.first?.becomeFirstResponder()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.visible = true
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		visible = false
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}


	// MARK: - Actions

	func submit() {
		// Subclasses should override this
	}

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


	// MARK: - Factory

	func secondaryButton(title title: String, emphasizedRange: NSRange) -> UIButton {
		let button = UIButton()
		button.titleLabel?.numberOfLines = 0
		button.titleLabel?.textAlignment = .Center

		let text = NSMutableAttributedString(string: title, attributes: [
			NSFontAttributeName: Font.sansSerif(weight: .bold, size: .subtitle),
			NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.7)
		])

		text.addAttribute(NSForegroundColorAttributeName, value: Color.white, range: emphasizedRange)
		button.setAttributedTitle(text, forState: .Normal)

		if let highlightedText = text.mutableCopy() as? NSMutableAttributedString {
			highlightedText.addAttribute(NSForegroundColorAttributeName, value: Color.white.colorWithAlphaComponent(0.9), range: NSRange(location: 0, length: highlightedText.length))
			highlightedText.addAttribute(NSForegroundColorAttributeName, value: Color.white, range: emphasizedRange)
			button.setAttributedTitle(highlightedText, forState: .Highlighted)
		}

		return button
	}
}


extension SessionsViewController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		let count = textFields.count
		for (i, field) in textFields.enumerate() {
			if field == textField && i < count - 1 {
				textFields[i + 1].becomeFirstResponder()
				return false
			}
		}

		submit()

		return false
	}

	func textFieldDidEndEditing(textField: UITextField) {
		// Workaround iOS bug that causes text to flicker when you lose focus
		textField.layoutIfNeeded()
	}
}
