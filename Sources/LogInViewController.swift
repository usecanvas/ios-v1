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

		emailTextField.accessibilityLabel = "Log in email or username"
		passwordTextField.accessibilityLabel = "Log in password"
		footerButton.set(preface: "Don’t have an account?", title: "Sign up.")

		let forgotButton = PrefaceButton()
		forgotButton.set(preface: "Trouble logging in?", title: "Reset your password.")
		forgotButton.addTarget(self, action: #selector(forgotPassword), forControlEvents: .TouchUpInside)
		stackView.addSpace(unit * 4)
		stackView.addArrangedSubview(forgotButton)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if view.hidden {
			return
		}
		
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
		OnePasswordExtension.sharedExtension().findLoginForURLString("https://usecanvas.com", forViewController: self, sender: sender, completion: login)
	}

	override func submit() {
		updateSubmitButton()
		guard submitButton.enabled, let username = emailTextField.text, password = passwordTextField.text else { return }

		loading = true

		let client = OAuthClient()
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
	
	private func login(onePassword loginDictionary: [NSObject: AnyObject]?, error: NSError?) {
		if let username = loginDictionary?[AppExtensionUsernameKey] as? String {
			emailTextField.text = username
		}
		
		if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
			passwordTextField.text = password
		}
		
		submit()
	}

	private func login(credential credential: SharedWebCredentials.Credential) {
		webCredential = credential
		emailTextField.text = credential.account
		passwordTextField.text = credential.password
		
		submit()
	}
}
