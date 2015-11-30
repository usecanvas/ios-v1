//
//  LoginViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import OnePasswordExtension

class LoginViewController: UIViewController {

	// MARK: - Properties

	let stackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .Vertical
		view.spacing = 16
		return view
	}()

	let usernameTextField: UITextField = {
		let field = LoginTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.placeholder = "Username or email"
		field.autocapitalizationType = .None
		field.autocorrectionType = .No
		field.returnKeyType = .Next
		return field
	}()

	let passwordTextField: UITextField = {
		let field = LoginTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.secureTextEntry = true
		field.placeholder = "Password"
		field.returnKeyType = .Go
		return field
	}()

	let submitButton: UIButton = {
		let button = Button()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = Color.white
		button.setTitleColor(Color.brand, forState: .Normal)
		button.setTitle("Login", forState: .Normal)
		return button
	}()

	private var loading = false {
		didSet {
			usernameTextField.enabled = !loading
			passwordTextField.enabled = !loading
			submitButton.enabled = !loading
			UIApplication.sharedApplication().networkActivityIndicatorVisible = loading
		}
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Color.brand

		// 1Password
		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
			button.setImage(UIImage(named: "OnePassword"), forState: .Normal)
			button.imageView?.tintColor = Color.white
			button.addTarget(self, action: "onePassword:", forControlEvents: .TouchUpInside)
			usernameTextField.rightView = button
			usernameTextField.rightViewMode = .Always
		}

		usernameTextField.delegate = self
		passwordTextField.delegate = self

		stackView.addArrangedSubview(usernameTextField)
		stackView.addArrangedSubview(passwordTextField)
		stackView.addArrangedSubview(submitButton)
		view.addSubview(stackView)

		NSLayoutConstraint.activateConstraints([
			stackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			stackView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 0.8),
			stackView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 64),
			submitButton.heightAnchor.constraintEqualToAnchor(usernameTextField.heightAnchor)
		])
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		usernameTextField.becomeFirstResponder()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}


	// MARK: - Actions

	@objc private func onePassword(sender: AnyObject?) {
		OnePasswordExtension.sharedExtension().findLoginForURLString("https://usecanvas.com", forViewController: self, sender: sender) { [weak self] loginDictionary, _ in
			if let username = loginDictionary?[AppExtensionUsernameKey] as? String {
				self?.usernameTextField.text = username
			}

			if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
				self?.passwordTextField.text = password
			}

			self?.signIn()
		}
	}

	private func signIn() {
		guard let username = usernameTextField.text, password = passwordTextField.text else { return }

		loading = true

		AuthorizationClient(baseURL: baseURL).login(username: username, password: password) { [weak self] in
			switch $0 {
			case .Success(let account):
				dispatch_async(dispatch_get_main_queue()) {
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					AccountController.sharedController.currentAccount = account
					Analytics.track(.LoggedIn)
				}
			case .Failure(let errorMessage):
				print("Login error: \(errorMessage)")
				dispatch_async(dispatch_get_main_queue()) { [weak self] in
					self?.loading = false
					self?.passwordTextField.becomeFirstResponder()
				}
			}
		}
	}
}


extension LoginViewController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == usernameTextField {
			passwordTextField.becomeFirstResponder()
		} else if textField == passwordTextField {
			signIn()
		}
		return false
	}
}