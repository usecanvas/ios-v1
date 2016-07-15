//
//  OnboardingViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

class OnboardingBillboardViewController: StackViewController {
	
	// MARK: - UIViewController

	var illustrationName: String? {
		didSet {
			updateIllustration()
		}
	}
	
	private let illustrationView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .Center
		return view
	}()
	
	var text: String? {
		get {
			return textLabel.text
		}
		
		set {
			textLabel.text = newValue
		}
	}
	
	private let textLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.black
		label.numberOfLines = 0
		label.textAlignment = .Center
		return label
	}()
	
	var detailText: String? {
		get {
			return detailTextLabel.text
		}
		
		set {
			detailTextLabel.text = newValue
		}
	}
	
	private let detailTextLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.darkGray
		label.numberOfLines = 0
		label.textAlignment = .Center
		return label
	}()
	
	private var textIllustrationSpacing: NSLayoutConstraint!
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		stackView.axis = .Vertical
		stackView.alignment = .Center
		stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16 + 44, right: 16)
		stackView.layoutMarginsRelativeArrangement = true
		
		stackView.addArrangedSubview(textLabel)
		stackView.addSpace(12)
		stackView.addArrangedSubview(detailTextLabel)
		
		let spacer = UIView()
		spacer.translatesAutoresizingMaskIntoConstraints = false
		stackView.addArrangedSubview(spacer)
		
		textIllustrationSpacing = spacer.heightAnchor.constraintEqualToConstant(0)
		textIllustrationSpacing.active = true
		
		stackView.addArrangedSubview(illustrationView)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFonts), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFonts()
	}
	
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		let spacing: CGFloat

		if view.bounds.height > 480 {
			spacing = traitCollection.horizontalSizeClass == .Regular ? 48 : 32
		} else {
			spacing = 16
		}

		textIllustrationSpacing.constant = spacing
		
		updateIllustration()
	}
	
	
	// MARK: - Private
	
	@objc private func updateFonts() {
		textLabel.font = TextStyle.title1.font()
		detailTextLabel.font = TextStyle.body.font()
	}
	
	private func updateIllustration() {
		guard let illustrationName = illustrationName else {
			illustrationView.image = nil
			return
		}
		
		var name = illustrationName
		
		switch traitCollection.horizontalSizeClass {
		case .Compact, .Unspecified:
			name += "Compact"
		case .Regular:
			name += "Regular"
		}
		
		illustrationView.image = UIImage(named: name)
	}
}
