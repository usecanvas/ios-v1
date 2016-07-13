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
		
		let footer = PrefaceButton()
		footer.translatesAutoresizingMaskIntoConstraints = false
		footer.set(preface: "Already have an account?", title: "Log in.")
		footer.layer.borderWidth = 0
//		footer.addTarget(self, action: #selector(logIn), forControlEvents: .TouchUpInside)
		view.addSubview(footer)
		
		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		footer.addSubview(line)
		
		NSLayoutConstraint.activateConstraints([
			container.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			container.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			container.topAnchor.constraintEqualToAnchor(view.topAnchor),
			container.bottomAnchor.constraintEqualToAnchor(footer.topAnchor),
			
			billboard.centerXAnchor.constraintEqualToAnchor(container.centerXAnchor),
			billboard.centerYAnchor.constraintEqualToAnchor(container.centerYAnchor),
			billboard.widthAnchor.constraintLessThanOrEqualToAnchor(container.widthAnchor),
			
			line.leadingAnchor.constraintEqualToAnchor(footer.leadingAnchor),
			line.trailingAnchor.constraintEqualToAnchor(footer.trailingAnchor),
			line.topAnchor.constraintEqualToAnchor(footer.topAnchor),
			
			footer.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			footer.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			footer.heightAnchor.constraintEqualToConstant(48),
			footer.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
	}
}
