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

final class LoginViewController: UIViewController {

	// MARK: - Properties

	let backgroundView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor(patternImage: UIImage(named: "Illustration")!)
		view.alpha = 0.07
		return view
	}()

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
		field.placeholder = LocalizedString.UsernamePlaceholder.string
		field.autocapitalizationType = .None
		field.autocorrectionType = .No
		field.returnKeyType = .Next
		return field
	}()

	let passwordTextField: UITextField = {
		let field = LoginTextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.secureTextEntry = true
		field.placeholder = LocalizedString.PasswordPlaceholder.string
		field.returnKeyType = .Go
		return field
	}()

	let resetPasswordButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
		button.setImage(UIImage(named: "help"), forState: .Normal)
		button.tintColor = .whiteColor()
		button.adjustsImageWhenHighlighted = false
		return button
	}()

	let submitButton: IndicatorButton = {
		let button = IndicatorButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = Color.white
		button.setTitle(LocalizedString.LoginButton.string, forState: .Normal)
		return button
	}()

	private var centerYConstraint: NSLayoutConstraint? {
		willSet {
			guard let old = centerYConstraint else { return }
			NSLayoutConstraint.deactivateConstraints([old])
		}

		didSet {
			guard let new = centerYConstraint else { return }
			NSLayoutConstraint.activateConstraints([new])
		}
	}

	private var keyboardFrame: CGRect? {
		didSet {
			guard let keyboardFrame = keyboardFrame else {
				centerYConstraint = nil
				return
			}

			var rect = view.bounds
			rect.size.height -= rect.intersect(keyboardFrame).height
			rect.origin.y += UIApplication.sharedApplication().statusBarFrame.size.height
			rect.size.height -= UIApplication.sharedApplication().statusBarFrame.size.height

			let contstraint = stackView.centerYAnchor.constraintEqualToAnchor(view.topAnchor, constant: rect.midY)
			contstraint.priority = UILayoutPriorityDefaultHigh

			centerYConstraint = contstraint
		}
	}

	private var loading = false {
		didSet {
			usernameTextField.enabled = !loading
			passwordTextField.enabled = !loading
			submitButton.enabled = !loading
			submitButton.loading = loading
			UIApplication.sharedApplication().networkActivityIndicatorVisible = loading
		}
	}

	private var visible = false


	// MARK: - Initializers

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Color.brand

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)

		// 1Password
		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
			button.setImage(UIImage(named: "OnePassword"), forState: .Normal)
			button.imageView?.tintColor = Color.white
			button.addTarget(self, action: #selector(onePassword), forControlEvents: .TouchUpInside)
			usernameTextField.rightView = button
			usernameTextField.rightViewMode = .Always
		}

		usernameTextField.delegate = self
		passwordTextField.delegate = self

		passwordTextField.rightViewMode = .Always
		passwordTextField.rightView = resetPasswordButton
		resetPasswordButton.addTarget(self, action: #selector(resetPassword), forControlEvents: .TouchUpInside)

		submitButton.addTarget(self, action: #selector(signIn), forControlEvents: .TouchUpInside)

		view.addSubview(backgroundView)

		stackView.addArrangedSubview(usernameTextField)
		stackView.addArrangedSubview(passwordTextField)
		stackView.addArrangedSubview(submitButton)
		view.addSubview(stackView)

		let width = stackView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 0.8)
		width.priority = UILayoutPriorityDefaultHigh

		let top = stackView.topAnchor.constraintGreaterThanOrEqualToAnchor(view.topAnchor, constant: 64)
		top.priority = UILayoutPriorityDefaultLow

		NSLayoutConstraint.activateConstraints([
			backgroundView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			backgroundView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			backgroundView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			backgroundView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),

			stackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			top,
			width,
			stackView.widthAnchor.constraintLessThanOrEqualToConstant(400),
			passwordTextField.heightAnchor.constraintEqualToAnchor(usernameTextField.heightAnchor),
			submitButton.heightAnchor.constraintEqualToAnchor(usernameTextField.heightAnchor)
		])
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		usernameTextField.becomeFirstResponder()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.visible = true
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		visible = false
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

	@objc private func signIn() {
		guard let username = usernameTextField.text, password = passwordTextField.text else { return }

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

	@objc private func keyboardWillChangeFrame(notification: NSNotification) {
		guard let dictionary = notification.userInfo as? [String: AnyObject],
			duration = dictionary[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,
			curve = (dictionary[UIKeyboardAnimationCurveUserInfoKey] as? Int).flatMap(UIViewAnimationCurve.init),
			rect = (dictionary[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
		else { return }

		let frame = view.convertRect(rect, fromView: nil)

		let change = { [weak self] in
			self?.keyboardFrame = frame
			self?.view.layoutIfNeeded()
		}

		if visible {
			UIView.beginAnimations(nil, context: nil)
			UIView.setAnimationDuration(duration)
			UIView.setAnimationCurve(curve)
			change()
			UIView.commitAnimations()
		} else {
			UIView.performWithoutAnimation(change)
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

	func textFieldDidEndEditing(textField: UITextField) {
		// Workaround iOS bug that causes text to flicker when you lose focus
		textField.layoutIfNeeded()
	}
}
