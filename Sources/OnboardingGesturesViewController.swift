//
//  OnboardingGesturesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class OnboardingGesturesViewController: OnboardingBillboardViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleLabel.text = "Easy to the Touch"
		subtitleLabel.text = "Swipe gestures turn paragraphs\ninto lists and headings."
	}
}
