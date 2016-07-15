//
//  VerifyViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

// TODO: Localize
final class VerifyViewController: UIViewController {

	// MARK: - Properties

	let logInButton: UIButton = {
		let button = FooterButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.set(preface: "Already have an account?", title: "Log in.")
		return button
	}()
	

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(container)
		
		let billboard = BillboardView()
		billboard.translatesAutoresizingMaskIntoConstraints = false
		billboard.illustrationView.image = UIImage(named: "Email")
		billboard.titleLabel.text = "Thanks for signing up."
		billboard.subtitleLabel.text = "We’ve sent you an email with a link to verify and activate your account."
		container.addSubview(billboard)

		view.addSubview(logInButton)
		
		NSLayoutConstraint.activateConstraints([
			container.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			container.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			container.topAnchor.constraintEqualToAnchor(view.topAnchor),
			container.bottomAnchor.constraintEqualToAnchor(logInButton.topAnchor),
			
			billboard.centerXAnchor.constraintEqualToAnchor(container.centerXAnchor),
			billboard.centerYAnchor.constraintEqualToAnchor(container.centerYAnchor),
			billboard.widthAnchor.constraintLessThanOrEqualToAnchor(container.widthAnchor),
			
			logInButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			logInButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			logInButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
	}
}
