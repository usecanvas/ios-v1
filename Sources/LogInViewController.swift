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

// TODO: Localize
final class LogInViewController: SessionFormViewController {

	// MARK: - Properties

	private var askedForWebCredential = false
	private var webCredential: SharedWebCredentials.Credential?
	private var loaded = false


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Log in to Canvas"

		submitButton.setTitle(LocalizedString.LogInButton.string, forState: .Normal)
		submitButton.enabled = false

		footerButton.set(preface: "Don’t have an account?", title: "Sign up.")

		let forgotButton = PrefaceButton()
		forgotButton.set(preface: "Trouble logging in?", title: "Reset your password.")
		forgotButton.addTarget(self, action: #selector(forgotPassword), forControlEvents: .TouchUpInside)
		stackView.addSpace(32)
		stackView.addArrangedSubview(forgotButton)

		// 1Password
		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
			button.setImage(UIImage(named: "1Password"), forState: .Normal)
			button.imageView?.tintColor = Swatch.gray
			button.addTarget(self, action: #selector(onePassword), forControlEvents: .TouchUpInside)
			button.adjustsImageWhenHighlighted = true
			passwordTextField.rightView = button
			passwordTextField.rightViewMode = .Always
		}
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Ignore the first viewDidAppear triggered by containment *sigh*
		if !loaded {
			loaded = true
			return
		}

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
			self?.login(onePassword: loginDictionary)
		}
	}

	override func submit() {
		guard submitButton.enabled, let username = emailTextField.text, password = passwordTextField.text
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


	// MARK: - Private
	
	private func login(onePassword loginDictionary: [NSObject: AnyObject]?) {
		if let username = loginDictionary?[AppExtensionUsernameKey] as? String {
			emailTextField.text = username
		}
		
		if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
			passwordTextField.text = password
		}
		
		updateSubmitButton()
		submit()
	}

	private func login(credential credential: SharedWebCredentials.Credential) {
		webCredential = credential
		emailTextField.text = credential.account
		passwordTextField.text = credential.password
		
		updateSubmitButton()
		submit()
	}
}
