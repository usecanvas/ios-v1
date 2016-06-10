//
//  LogInViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import OnePasswordExtension

final class LogInViewController: SessionsViewController {

	// MARK: - Properties

	let usernameContainer: TextFieldContainer = {
		let container = TextFieldContainer(textField: LoginTextField())
		container.translatesAutoresizingMaskIntoConstraints = false
		container.textField.keyboardType = .EmailAddress
		container.textField.placeholder = LocalizedString.LoginPlaceholder.string
		container.textField.returnKeyType = .Next
		container.textField.autocapitalizationType = .None
		container.textField.autocorrectionType = .No

		container.visualEffectView.layer.cornerRadius = container.textField.layer.cornerRadius
		container.visualEffectView.layer.masksToBounds = true
		return container
	}()

	override var textFields: [UITextField] {
		return [usernameContainer.textField, passwordContainer.textField]
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// Shared Web Credentials
		SharedWebCredentials.get { [weak self] credential, _ in
			guard let credential = credential else { return }

			dispatch_async(dispatch_get_main_queue()) {
				self?.login(credential: credential)
			}
		}

		// 1Password
		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
			button.setImage(UIImage(named: "OnePassword"), forState: .Normal)
			button.imageView?.tintColor = Color.white
			button.addTarget(self, action: #selector(onePassword), forControlEvents: .TouchUpInside)
			usernameContainer.textField.rightView = button
			usernameContainer.textField.rightViewMode = .Always
		}

		let resetPasswordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
		resetPasswordButton.setImage(UIImage(named: "help"), forState: .Normal)
		resetPasswordButton.tintColor = Color.white
		resetPasswordButton.adjustsImageWhenHighlighted = false

		passwordContainer.textField.rightViewMode = .Always
		passwordContainer.textField.rightView = resetPasswordButton
		resetPasswordButton.addTarget(self, action: #selector(resetPassword), forControlEvents: .TouchUpInside)

		submitButton.setTitle(LocalizedString.LoginButton.string, forState: .Normal)

		stackView.addArrangedSubview(usernameContainer)
		stackView.addArrangedSubview(passwordContainer)
		stackView.addArrangedSubview(submitButton)

		let signUpButton = secondaryButton(title: "Don’t have an account yet? Sign\u{202F}up.", emphasizedRange: NSRange(location: 27, length: 7))
		signUpButton.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
		stackView.addArrangedSubview(signUpButton)

		NSLayoutConstraint.activateConstraints([
			usernameContainer.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor),
			passwordContainer.widthAnchor.constraintEqualToAnchor(usernameContainer.widthAnchor),
			passwordContainer.heightAnchor.constraintEqualToAnchor(usernameContainer.heightAnchor),
			submitButton.widthAnchor.constraintEqualToAnchor(usernameContainer.widthAnchor),
			submitButton.heightAnchor.constraintEqualToAnchor(usernameContainer.heightAnchor)
		])

		if view.bounds.height > 480 {
			let logo = UIImageView(image: UIImage(named: "logo-small"))
			logo.layer.cornerRadius = 8
			logo.layer.masksToBounds = true
			stackView.insertArrangedSubview(logo, atIndex: 0)

			if view.bounds.height > 568 {
				stackView.insertArrangedSubview(SpaceView(height: 0), atIndex: 1)
			}
		}
	}


	// MARK: - Actions

	@objc private func onePassword(sender: AnyObject?) {
		OnePasswordExtension.sharedExtension().findLoginForURLString("https://usecanvas.com", forViewController: self, sender: sender) { [weak self] loginDictionary, _ in
			if let username = loginDictionary?[AppExtensionUsernameKey] as? String {
				self?.usernameContainer.textField.text = username
			}

			if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
				self?.passwordContainer.textField.text = password
			}

			self?.submit()
		}
	}

	override func submit() {
		guard let username = usernameContainer.textField.text, password = passwordContainer.textField.text
		where !username.isEmpty && !password.isEmpty
		else { return }

		loading = true

		let client = AuthorizationClient(clientID: config.canvasClientID, clientSecret: config.canvasClientSecret, baseURL: config.baseURL)
		client.createAccessToken(username: username, password: password) { [weak self] in
			switch $0 {
			case .Success(let account):
				dispatch_async(dispatch_get_main_queue()) {
					SharedWebCredentials.add(domain: "usecanvas.com", account: username, password: password)
					
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					AccountController.sharedController.currentAccount = account
					Analytics.track(.LoggedIn)
				}
			case .Failure(let errorMessage):
				dispatch_async(dispatch_get_main_queue()) { [weak self] in
					self?.loading = false
					self?.passwordContainer.textField.becomeFirstResponder()
					
					let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: LocalizedString.Okay.string, style: .Cancel, handler: nil))
					self?.presentViewController(alert, animated: true, completion: nil)
				}
			}
		}
	}

	@objc private func resetPassword() {
		let URL = NSURL(string: "https://usecanvas.com/password-reset")!
		UIApplication.sharedApplication().openURL(URL)
	}

	@objc private func signUp() {
		let URL = NSURL(string: "https://usecanvas.com/signup")!
		UIApplication.sharedApplication().openURL(URL)
	}


	// MARK: - Private

	private func login(credential credential: SharedWebCredentials.Credential) {
		usernameContainer.textField.text = credential.account
		passwordContainer.textField.text = credential.password
		submit()
	}
}
