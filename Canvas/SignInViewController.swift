//
//  SignInViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit
import OnePasswordExtension

class SignInViewController: TableViewController {

	// MARK: - Properties

	let usernameTextField: UITextField = {
		let field = UITextField(frame: CGRect(x: 0, y: 0, width: 240, height: 44))
		field.placeholder = "user"
		field.autocapitalizationType = .None
		field.autocorrectionType = .No
		field.returnKeyType = .Next
		return field
	}()

	let passwordTextField: UITextField = {
		let field = UITextField(frame: CGRect(x: 0, y: 0, width: 240, height: 44))
		field.secureTextEntry = true
		field.placeholder = "password"
		field.returnKeyType = .Go
		return field
	}()

	private var loading = false {
		didSet {
			usernameTextField.enabled = !loading
			passwordTextField.enabled = !loading
			UIApplication.sharedApplication().networkActivityIndicatorVisible = loading
		}
	}


	// MARK: - Initializers

	convenience init() {
		self.init(style: .Grouped)
		title = "Canvas"
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "OnePassword"), landscapeImagePhone: nil, style: .Plain, target: self, action: "onePassword:")
		}

		usernameTextField.delegate = self
		passwordTextField.delegate = self

		dataSource.sections = [
			Section(rows: [
				Row(text: "Username", accessory: .View(usernameTextField)),
				Row(text: "Password", accessory: .View(passwordTextField))
			]),
			Section(rows: [
				Row(text: "Sign In", cellClass: ButtonCell.self, selection: signIn)
			])
		]
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		usernameTextField.becomeFirstResponder()
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

		AuthorizationClient().signIn(username: username, password: password) { [weak self] in
			switch $0 {
			case .Success(let account):
				dispatch_async(dispatch_get_main_queue()) {
					AccountController.sharedController.currentAccount = account
				}
			case .Failure(let errorMessage):
				print("Error: \(errorMessage)")
				dispatch_async(dispatch_get_main_queue()) { [weak self] in
					self?.loading = false
					self?.passwordTextField.becomeFirstResponder()
				}
			}
		}
	}
}


extension SignInViewController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == usernameTextField {
			passwordTextField.becomeFirstResponder()
		} else if textField == passwordTextField {
			signIn()
		}
		return false
	}
}

