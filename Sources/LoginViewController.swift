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

final class LoginViewController: SessionsViewController {

	// MARK: - Properties

	let loginTextField: UITextField = {
		let field = LoginTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.placeholder = LocalizedString.LoginPlaceholder.string
		field.autocapitalizationType = .None
		field.autocorrectionType = .No
		field.returnKeyType = .Next
		field.keyboardType = .EmailAddress
		return field
	}()

	override var textFields: [UITextField] {
		return [loginTextField, passwordTextField]
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// 1Password
		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
			button.setImage(UIImage(named: "OnePassword"), forState: .Normal)
			button.imageView?.tintColor = Color.white
			button.addTarget(self, action: #selector(onePassword), forControlEvents: .TouchUpInside)
			loginTextField.rightView = button
			loginTextField.rightViewMode = .Always
		}

		let resetPasswordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
		resetPasswordButton.setImage(UIImage(named: "help"), forState: .Normal)
		resetPasswordButton.tintColor = .whiteColor()
		resetPasswordButton.adjustsImageWhenHighlighted = false

		passwordTextField.rightViewMode = .Always
		passwordTextField.rightView = resetPasswordButton
		resetPasswordButton.addTarget(self, action: #selector(resetPassword), forControlEvents: .TouchUpInside)

		submitButton.setTitle(LocalizedString.LoginButton.string, forState: .Normal)

		func label(text: String) -> UILabel {
			let label = UILabel()
			label.text = text
			label.font = Font.sansSerif(weight: .Bold, size: .Subtitle)
			label.textColor = .whiteColor()
			return label
		}

		let usernameLabel = label(LocalizedString.LoginLabel.string)
		let passwordLabel = label(LocalizedString.PasswordLabel.string)

		stackView.addArrangedSubview(usernameLabel)
		stackView.addSpace(4)
		stackView.addArrangedSubview(loginTextField)
		stackView.addSpace(16)

		stackView.addArrangedSubview(passwordLabel)
		stackView.addSpace(4)
		stackView.addArrangedSubview(passwordTextField)
		stackView.addSpace(16)

		stackView.addArrangedSubview(submitButton)
		stackView.addSpace(16)

		let signUpLabel = UILabel()
		signUpLabel.textAlignment = .Center

		let text = NSMutableAttributedString(string: "Don’t have an account yet? Sign up.", attributes: [
			NSFontAttributeName: Font.sansSerif(weight: .Bold, size: .Subtitle),
			NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.7)
		])

		text.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location: 27, length: 7))
		signUpLabel.attributedText = text

		stackView.addArrangedSubview(signUpLabel)

		NSLayoutConstraint.activateConstraints([
			passwordTextField.heightAnchor.constraintEqualToAnchor(loginTextField.heightAnchor),
			submitButton.heightAnchor.constraintEqualToAnchor(loginTextField.heightAnchor)
		])
	}


	// MARK: - Actions

	@objc private func onePassword(sender: AnyObject?) {
		OnePasswordExtension.sharedExtension().findLoginForURLString("https://usecanvas.com", forViewController: self, sender: sender) { [weak self] loginDictionary, _ in
			if let username = loginDictionary?[AppExtensionUsernameKey] as? String {
				self?.loginTextField.text = username
			}

			if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
				self?.passwordTextField.text = password
			}

			self?.submit()
		}
	}

	override func submit() {
		guard let username = loginTextField.text, password = passwordTextField.text else { return }

		loading = true

		let client = AuthorizationClient(clientID: config.canvasClientID, clientSecret: config.canvasClientSecret, baseURL: config.baseURL)
		client.createAccessToken(username: username, password: password) { [weak self] in
			switch $0 {
			case .Success(let account):
				dispatch_async(dispatch_get_main_queue()) {
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					AccountController.sharedController.currentAccount = account
					Analytics.track(.LoggedIn)
				}
			case .Failure(let errorMessage):
				dispatch_async(dispatch_get_main_queue()) { [weak self] in
					self?.loading = false
					self?.passwordTextField.becomeFirstResponder()
					
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
}
