//
//  OnboardingWelcomeViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

// TODO: Localize
final class OnboardingWelcomeViewController: OnboardingBillboardViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleLabel.text = "Welcome to Canvas"
		subtitleLabel.text = "Collaborative notes\nfor teams of nerds."
		illustrationView.image = UIImage(named: "OnboardingWelcome")
	}
}
