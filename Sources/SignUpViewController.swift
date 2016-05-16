//
//  SignUpViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/16/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import OnePasswordExtension

final class SignUpViewController: SessionsViewController {

	// MARK: - Properties

	let usernameTextField: UITextField = {
		let field = LoginTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.placeholder = "username"
		field.autocapitalizationType = .None
		field.autocorrectionType = .No
		field.returnKeyType = .Next
		return field
	}()

	let emailTextField: UITextField = {
		let field = LoginTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.placeholder = "email@example.com"
		field.autocapitalizationType = .None
		field.autocorrectionType = .No
		field.returnKeyType = .Next
		field.keyboardType = .EmailAddress
		return field
	}()

	override var textFields: [UITextField] {
		return [usernameTextField, emailTextField, passwordTextField]
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		submitButton.setTitle("Sign Up", forState: .Normal)

		let usernameLabel = label("Username")
		let emailLabel = label("Email")
		let passwordLabel = label(LocalizedString.PasswordLabel.string)

		stackView.addArrangedSubview(usernameLabel)
		stackView.addSpace(4)
		stackView.addArrangedSubview(usernameTextField)
		stackView.addSpace(16)

		stackView.addArrangedSubview(emailLabel)
		stackView.addSpace(4)
		stackView.addArrangedSubview(emailTextField)
		stackView.addSpace(16)

		stackView.addArrangedSubview(passwordLabel)
		stackView.addSpace(4)
		stackView.addArrangedSubview(passwordTextField)
		stackView.addSpace(16)

		stackView.addArrangedSubview(submitButton)
		stackView.addSpace(16)

		let logInButton = secondaryButton(title: "Already have an account? Log in.", emphasizedRange: NSRange(location: 25, length: 6))
		logInButton.addTarget(self, action: #selector(logIn), forControlEvents: .TouchUpInside)
		stackView.addArrangedSubview(logInButton)

		NSLayoutConstraint.activateConstraints([
			passwordTextField.heightAnchor.constraintEqualToAnchor(usernameTextField.heightAnchor),
			submitButton.heightAnchor.constraintEqualToAnchor(usernameTextField.heightAnchor)
		])
	}


	// MARK: - Actions

	override func submit() {
		// TODO
	}

	@objc private func logIn() {
		guard let rootViewController = parentViewController as? RootViewController else { return }
		rootViewController.viewController = LogInViewController()
	}
}
