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

	// TODO: lol gross
	private static let fieldWidth = UIScreen.mainScreen().bounds.width - (UI_USER_INTERFACE_IDIOM() == .Pad ? 200 : 130)

	let usernameTextField: UITextField = {
		let field = UITextField(frame: CGRect(x: 0, y: 0, width: fieldWidth, height: 44))
		field.placeholder = "user"
		field.autocapitalizationType = .None
		field.autocorrectionType = .No
		field.returnKeyType = .Next
		return field
	}()

	let passwordTextField: UITextField = {
		let field = UITextField(frame: CGRect(x: 0, y: 0, width: fieldWidth, height: 44))
		field.secureTextEntry = true
		field.placeholder = "password"
		field.returnKeyType = .Go
		return field
	}()

	let signInButton: UIButton = {
		let button = Button(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
		button.setTitle("Login", forState: .Normal)
		return button
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

		view.backgroundColor = Color.lightGray

		tableView.rowHeight = 48

		if view.bounds.height < 500 {
			tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
		}

		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: tableView.rowHeight))
			button.setImage(UIImage(named: "OnePassword"), forState: .Normal)
			button.imageView?.tintColor = Color.brand
			button.addTarget(self, action: "onePassword:", forControlEvents: .TouchUpInside)
			usernameTextField.rightView = button
			usernameTextField.rightViewMode = .Always
		}

		usernameTextField.delegate = self
		passwordTextField.delegate = self

		let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
		footer.addSubview(signInButton)

		dataSource.sections = [
			Section(rows: [
				Row(text: "Username", accessory: .View(usernameTextField)),
				Row(text: "Password", accessory: .View(passwordTextField))
			]),
			Section(footer: .View(footer))
		]
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		usernameTextField.becomeFirstResponder()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		signInButton.frame = CGRect(
			x: tableView.separatorInset.left,
			y: 0,
			width: tableView.bounds.width - (tableView.separatorInset.left * 2),
			height: 44
		)
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

		AuthorizationClient(baseURL: baseURL).signIn(username: username, password: password) { [weak self] in
			switch $0 {
			case .Success(let account):
				print("accessToken: \(account.accessToken)")
				dispatch_async(dispatch_get_main_queue()) {
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					AccountController.sharedController.currentAccount = account
					Analytics.track(.LoggedIn)
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
