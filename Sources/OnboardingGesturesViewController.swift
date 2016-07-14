//
//  OnboardingGesturesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

// TODO: Localize
final class OnboardingGesturesViewController: OnboardingBillboardViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		text = "Easy to the Touch"
		detailText = "Swipe gestures turn paragraphs\ninto lists and headings."
		illustrationName = "Gestures"
	}
}
