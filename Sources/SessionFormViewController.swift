//
//  SessionFormViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/16/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import CanvasText

class SessionFormViewController: StackViewController {

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
		button.enabled = false
		return button
	}()

	let footerButton: FooterButton = {
		let button = FooterButton()
		button.translatesAutoresizingMaskIntoConstraints = false
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

	var unit: CGFloat {
		return view.bounds.height > 480 ? 8 : 4
	}


	// MARK: - UIViewController

	override var title: String? {
		didSet {
			headingLabel.text = title
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let unit = self.unit

		// Icon
		if view.bounds.height > 568 {
			stackView.addArrangedSubview(iconView)
			stackView.addSpace(unit * 2)
		}

		// Title
		if view.bounds.height > 480 {
			stackView.addArrangedSubview(headingLabel)
			stackView.addSpace(unit)
		}

		// Text fields
		textFields.forEach { textField in
			stackView.addSpace(unit * 2)
			stackView.addArrangedSubview(textField)
			textField.delegate = self
			textField.addTarget(self, action: #selector(updateSubmitButton), forControlEvents: .EditingChanged)
		}

		stackView.addSpace(unit * 4)
		submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
		stackView.addArrangedSubview(submitButton)

		view.addSubview(footerButton)

		NSLayoutConstraint.activateConstraints([
			footerButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			footerButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			footerButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFonts), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFonts()
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
		view.addGestureRecognizer(tap)
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		endEditing()
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
	
	
	// MARK: - Private
	
	@objc private func updateFonts() {
		headingLabel.font = TextStyle.title2.font()
	}
	
	@objc private func endEditing() {
		view.endEditing(false)
	}
}


extension SessionFormViewController: UITextFieldDelegate {
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
