//
//  OnboardingOrigamiViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

// TODO: Localize
final class OnboardingOrigamiViewController: OnboardingBillboardViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		text = "Origami Markdown"
		detailText = "Folds away Markdown syntax\nwhen you don’t need it."
		illustrationName = "Origami"
	}
}
