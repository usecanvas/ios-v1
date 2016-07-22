//
//  VerifyViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit

// TODO: Localize
final class VerifyViewController: UIViewController {

	// MARK: - Properties

	private let billboardView: BillboardView = {
		let billboard = BillboardView()
		billboard.translatesAutoresizingMaskIntoConstraints = false
		billboard.illustrationView.image = UIImage(named: "Email")
		return billboard
	}()

	private var verifying = false {
		didSet {
			updateBillboard()
		}
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(container)

		updateBillboard()
		container.addSubview(billboardView)

		if showsMailButton() {
			let button = PillButton()
			button.translatesAutoresizingMaskIntoConstraints = false
			button.setTitle("Open Mail", forState: .Normal)
			button.addTarget(self, action: #selector(openMail), forControlEvents: .TouchUpInside)
			view.addSubview(button)

			NSLayoutConstraint.activateConstraints([
				button.centerXAnchor.constraintEqualToAnchor(billboardView.centerXAnchor),
				button.topAnchor.constraintEqualToAnchor(billboardView.bottomAnchor, constant: 32)
			])
		}


		let logInButton = FooterButton()
		logInButton.translatesAutoresizingMaskIntoConstraints = false
		logInButton.set(preface: "Already have an account?", title: "Log in.")
		logInButton.addTarget(self, action: #selector(logIn), forControlEvents: .TouchUpInside)
		view.addSubview(logInButton)

		let width = container.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 0.8)
		width.priority = UILayoutPriorityDefaultHigh
		
		NSLayoutConstraint.activateConstraints([
			container.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			container.topAnchor.constraintEqualToAnchor(view.topAnchor),
			container.bottomAnchor.constraintEqualToAnchor(logInButton.topAnchor),
			width,
			container.widthAnchor.constraintLessThanOrEqualToConstant(400),
			
			billboardView.centerXAnchor.constraintEqualToAnchor(container.centerXAnchor),
			billboardView.centerYAnchor.constraintEqualToAnchor(container.centerYAnchor),
			billboardView.widthAnchor.constraintLessThanOrEqualToAnchor(container.widthAnchor),
			
			logInButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			logInButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			logInButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
	}


	// MARK: - Verifying

	func verify(token token: String) {
		if verifying {
			return
		}

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		verifying = true

		let client = AuthorizationClient()
		client.verifyAccount(token: token) { result in
			dispatch_async(dispatch_get_main_queue()) { [weak self] in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false

				switch result {
				case .Success(let account):
					AccountController.sharedController.currentAccount = account
				case .Failure(let errorMessage):
					self?.verifying = false

					let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { _ in
						let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? RootViewController
						rootViewController?.viewController = OnboardingViewController()
					})
					self?.presentViewController(alert, animated: true, completion: nil)
				}
			}
		}
	}


	// MARK: - Actions

	@objc private func logIn() {
		guard let url = NSURL(string: "canvas://login") else { return }
		UIApplication.sharedApplication().openURL(url)
	}

	@objc private func openMail() {
		guard let url = NSURL(string: "message:message-id") else { return }
		UIApplication.sharedApplication().openURL(url)
	}


	// MARK: - Private

	private func showsMailButton() -> Bool {
		guard let url = NSURL(string: "message:message-id") else { return false }
		return UIApplication.sharedApplication().canOpenURL(url)
	}

	private func updateBillboard() {
		if verifying {
			billboardView.titleLabel.text = "Verifying…"
			billboardView.subtitleLabel.text = "We’ve verifying your account. Just a second."
		} else {
			billboardView.titleLabel.text = "Thanks for signing up."
			billboardView.subtitleLabel.text = "We’ve sent you an email with a link to verify and activate your account."
		}
	}
}
