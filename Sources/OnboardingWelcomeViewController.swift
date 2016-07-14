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
		
		text = "Welcome to Canvas"
		detailText = "Collaborative notes\nfor teams of nerds."
		illustrationName = "Welcome"
	}
}
