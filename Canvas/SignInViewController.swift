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

class SignInViewController: TableViewController {

	// MARK: - Properties

	let usernameTextField: UITextField = {
		let field = UITextField(frame: CGRect(x: 0, y: 0, width: 240, height: 44))
		field.placeholder = "user"
		return field
	}()

	let passwordTextField: UITextField = {
		let field = UITextField(frame: CGRect(x: 0, y: 0, width: 240, height: 44))
		field.secureTextEntry = true
		field.placeholder = "password"
		return field
	}()

	let activityIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView()
		view.activityIndicatorViewStyle = .Gray
		view.hidesWhenStopped = true
		return view
	}()

	private var loading = false {
		didSet {
			usernameTextField.enabled = !loading
			passwordTextField.enabled = !loading

			if loading {
				activityIndicator.startAnimating()
			} else {
				activityIndicator.stopAnimating()
			}
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

		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

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


	// MARK: - Private

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

