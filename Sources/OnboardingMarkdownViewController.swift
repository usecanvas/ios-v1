//
//  OnboardingMarkdownViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class OnboardingMarkdownViewController: OnboardingBillboardViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleLabel.text = "Origami Markdown"
		subtitleLabel.text = "Folds away Markdown syntax\nwhen you don’t need it."
		illustrationView.image = UIImage(named: "OnboardingMarkdown")
	}
}
