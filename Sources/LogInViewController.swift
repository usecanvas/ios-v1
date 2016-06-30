//
//  LogInViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import OnePasswordExtension

final class LogInViewController: SessionsViewController {

	// MARK: - Properties

	private var askedForWebCredential = false
	private var webCredential: SharedWebCredentials.Credential?


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Log in to Canvas"
		submitButton.setTitle(LocalizedString.LoginButton.string, forState: .Normal)

		let signUpText = self.dynamicType.secondaryButtonText(title: "Don’t have an account? Sign up.", emphasizedRange: NSRange(location: 23, length: 7))
		footerButton.setAttributedTitle(signUpText, forState: .Normal)
		footerButton.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)

		let forgotButton = self.dynamicType.secondaryButton(title: "Trouble logging in? Reset your password.", emphasizedRange: NSRange(location: 20, length: 19))
		forgotButton.addTarget(self, action: #selector(forgotPassword), forControlEvents: .TouchUpInside)
		stackView.addSpace(32)
		stackView.addArrangedSubview(forgotButton)

		// 1Password
		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
			button.setImage(UIImage(named: "1Password"), forState: .Normal)
			button.imageView?.tintColor = Swatch.gray
			button.addTarget(self, action: #selector(onePassword), forControlEvents: .TouchUpInside)
			passwordTextField.rightView = button
			passwordTextField.rightViewMode = .Always
		}
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		// Make sure we only do this once
		if askedForWebCredential {
			return
		}
		askedForWebCredential = true

		// Query for shared web credentials
		SharedWebCredentials.get { [weak self] credential, _ in
			guard let credential = credential else { return }

			dispatch_async(dispatch_get_main_queue()) {
				self?.login(credential: credential)
			}
		}
	}


	// MARK: - Actions

	override func onePassword(sender: AnyObject?) {
		OnePasswordExtension.sharedExtension().findLoginForURLString("https://usecanvas.com", forViewController: self, sender: sender) { [weak self] loginDictionary, _ in
			if let username = loginDictionary?[AppExtensionUsernameKey] as? String {
				self?.emailTextField.text = username
			}

			if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
				self?.passwordTextField.text = password
			}

			self?.submit()
		}
	}

	override func submit() {
		guard let username = emailTextField.text, password = passwordTextField.text
			where !username.isEmpty && !password.isEmpty
			else { return }

		loading = true

		let client = AuthorizationClient(clientID: config.canvasClientID, clientSecret: config.canvasClientSecret, baseURL: config.environment.baseURL)
		client.createAccessToken(username: username, password: password) { [weak self] in
			switch $0 {
			case .Success(let account):
				dispatch_async(dispatch_get_main_queue()) {
					if let this = self where this.webCredential == nil {
						SharedWebCredentials.add(domain: "usecanvas.com", account: username, password: password)
					}

					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					AccountController.sharedController.currentAccount = account
					Analytics.track(.LoggedIn)
				}
			case .Failure(let errorMessage):
				dispatch_async(dispatch_get_main_queue()) { [weak self] in
					self?.loading = false
					self?.passwordTextField.becomeFirstResponder()
					self?.webCredential = nil

					let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: LocalizedString.Okay.string, style: .Cancel, handler: nil))
					self?.presentViewController(alert, animated: true, completion: nil)
				}
			}
		}
	}

	@objc private func forgotPassword() {
		let URL = NSURL(string: "https://usecanvas.com/password-reset")!
		UIApplication.sharedApplication().openURL(URL)
	}

	@objc private func signUp() {
		let viewController = SignUpViewController()
		navigationController?.pushViewController(viewController, animated: true)
	}


	// MARK: - Private

	private func login(credential credential: SharedWebCredentials.Credential) {
		webCredential = credential
		emailTextField.text = credential.account
		passwordTextField.text = credential.password
		submit()
	}
}
