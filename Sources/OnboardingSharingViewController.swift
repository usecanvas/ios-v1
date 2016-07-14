//
//  OnboardingSharingViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

// TODO: Localize
final class OnboardingSharingViewController: OnboardingBillboardViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		text = "Simple Sharing"
		detailText = "Collaboration is as easy\nas sharing a URL."
		illustrationName = "Share"
	}
}
