//
//  CanvasIconView.swift
//  Canvas
//
//  Created by Sam Soffes on 1/14/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit

final class CanvasIconView: TintableView {

	// MARK: - Properties

	override var highlighted: Bool {
		didSet {
			globeView.highlighted = highlighted
		}
	}

	var canvas: Canvas? {
		didSet {
			guard let canvas = canvas else { return }

			iconView.image = canvas.kind.icon.imageWithRenderingMode(.AlwaysTemplate)
			globeView.hidden = canvas.readOnly
			globeView.normalTintColor = canvas.organization.color
		}
	}

	private let iconView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .Center
		return view
	}()

	private let globeView: GlobeView = {
		let view = GlobeView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.highlightedTintColor = .whiteColor()
		return view
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(iconView)
		addSubview(globeView)

		NSLayoutConstraint.activateConstraints([
			iconView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			iconView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			iconView.topAnchor.constraintEqualToAnchor(topAnchor),
			iconView.bottomAnchor.constraintEqualToAnchor(bottomAnchor),

			globeView.leadingAnchor.constraintEqualToAnchor(iconView.leadingAnchor),
			globeView.trailingAnchor.constraintEqualToAnchor(iconView.trailingAnchor),
			globeView.topAnchor.constraintEqualToAnchor(iconView.topAnchor),
			globeView.bottomAnchor.constraintEqualToAnchor(iconView.bottomAnchor)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()

		globeView.tintColor = canvas?.organization.color
	}
}


private final class GlobeView: TintableView {

	// MARK: - Properties

	private let globeView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.image = UIImage(named: "Document Globe")
		return imageView
	}()

	private let backgroundView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.image = UIImage(named: "Document Globe-Background")
		return imageView
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(backgroundView)
		addSubview(globeView)

		NSLayoutConstraint.activateConstraints([
			backgroundView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			backgroundView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			backgroundView.topAnchor.constraintEqualToAnchor(topAnchor),
			backgroundView.bottomAnchor.constraintEqualToAnchor(bottomAnchor),

			globeView.leadingAnchor.constraintEqualToAnchor(backgroundView.leadingAnchor),
			globeView.trailingAnchor.constraintEqualToAnchor(backgroundView.trailingAnchor),
			globeView.topAnchor.constraintEqualToAnchor(backgroundView.topAnchor),
			globeView.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func intrinsicContentSize() -> CGSize {
		return CGSize(width: 32, height: 32)
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()

		if highlighted {
			globeView.tintColor = normalTintColor
			backgroundView.tintColor = highlightedTintColor
		} else {
			globeView.tintColor = highlightedTintColor
			backgroundView.tintColor = normalTintColor
		}
	}
}
