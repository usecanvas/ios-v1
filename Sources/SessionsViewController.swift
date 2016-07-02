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
import CanvasText

class SessionsViewController: StackViewController {

	// MARK: - Properties

	let iconView: UIView = {
		let stackView = UIStackView()
		stackView.axis = .Vertical
		stackView.alignment = .Center

		let imageView = UIImageView(image: UIImage(named: "Icon-Small"))
		stackView.addArrangedSubview(imageView)

		return stackView
	}()

	let headingLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.black
		label.textAlignment = .Center
		return label
	}()

	let emailTextField: UITextField = {
		let textField = TextField()
		textField.keyboardType = .EmailAddress
		textField.placeholder = LocalizedString.LoginPlaceholder.string
		textField.returnKeyType = .Next
		textField.autocapitalizationType = .None
		textField.autocorrectionType = .No
		return textField
	}()

	let passwordTextField: UITextField = {
		let textField = TextField()
		textField.secureTextEntry = true
		textField.placeholder = LocalizedString.PasswordPlaceholder.string
		textField.returnKeyType = .Go
		return textField
	}()

	let submitButton: IndicatorButton = {
		let button = IndicatorButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	let footerButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false

		let lineView = LineView()
		lineView.translatesAutoresizingMaskIntoConstraints = false
		lineView.backgroundColor = Swatch.border
		button.addSubview(lineView)

		NSLayoutConstraint.activateConstraints([
			lineView.widthAnchor.constraintEqualToAnchor(button.widthAnchor),
			lineView.topAnchor.constraintEqualToAnchor(button.topAnchor)
		])

		return button
	}()

	var textFields: [UITextField] {
		return [emailTextField, passwordTextField]
	}

	var loading = false {
		didSet {
			textFields.forEach { $0.enabled = !loading }
			submitButton.enabled = !loading
			submitButton.loading = loading
			UIApplication.sharedApplication().networkActivityIndicatorVisible = loading
		}
	}


	// MARK: - UIViewController

	override var title: String? {
		didSet {
			headingLabel.text = title
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Icon
		if view.bounds.height > 480 {
			stackView.addArrangedSubview(iconView)

			if view.bounds.height > 568 {
				stackView.addSpace(16)
				stackView.addArrangedSubview(headingLabel)
				stackView.addSpace(8)
			} else {
				stackView.addSpace(16)
			}
		}

		// Text fields
		textFields.forEach { textField in
			stackView.addSpace(16)
			stackView.addArrangedSubview(textField)
			textField.delegate = self
			textField.addTarget(self, action: #selector(updateSubmitButton), forControlEvents: .EditingChanged)
		}

		stackView.addSpace(32)
		submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
		stackView.addArrangedSubview(submitButton)

		view.addSubview(footerButton)

		NSLayoutConstraint.activateConstraints([
			footerButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			footerButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			footerButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
			footerButton.heightAnchor.constraintEqualToConstant(48)
		])
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFonts), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFonts()
	}


	// MARK: - Actions

	func submit() {
		// Subclasses should override this
	}

	func onePassword(sender: AnyObject?) {
		// Subclasses should override this
	}
	
	func updateSubmitButton() {
		var enabled = true
		
		textFields.forEach { textField in
			if textField.text?.isEmpty ?? true {
				enabled = false
			}
		}
		
		submitButton.enabled = enabled
	}


	// MARK: - Factory

//	static func secondaryButtonText(title title: String, emphasizedRange: NSRange) -> NSAttributedString {
//		let text = NSMutableAttributedString(string: title, attributes: [
//			NSFontAttributeName: Font.sansSerif(size: .subtitle),
//			NSForegroundColorAttributeName: Swatch.gray
//		])
//
//		text.setAttributes([
//			NSFontAttributeName: Font.sansSerif(size: .subtitle, weight: .medium),
//			NSForegroundColorAttributeName: Swatch.brand
//		], range: emphasizedRange)
//
//		return text
//	}
//
//	static func secondaryButton(title title: String, emphasizedRange: NSRange) -> UIButton {
//		let button = UIButton()
//		button.titleLabel?.numberOfLines = 0
//		button.titleLabel?.textAlignment = .Center
//
//		let text = secondaryButtonText(title: title, emphasizedRange: emphasizedRange)
//
//		button.setAttributedTitle(text, forState: .Normal)
//
//		return button
//	}
	
	
	// MARK: - Private
	
	@objc private func updateFonts() {
		headingLabel.font = TextStyle.title2.font()
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
