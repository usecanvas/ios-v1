//
//  SearchBarContainer.swift
//  Canvas
//
//  Created by Sam Soffes on 2/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class SearchBarContainer: UIView {

	// MARK: - Properties

	let searchBar: UISearchBar

	private let topBorderView = UIView()
	private let bottomBorderView = UIView()


	// MARK: - Initializers

	init(searchBar: UISearchBar) {
		self.searchBar = searchBar

		super.init(frame: searchBar.bounds)

		autoresizingMask = [.FlexibleWidth]

		searchBar.barTintColor = Color.white
		searchBar.layer.borderColor = Color.white.CGColor
		searchBar.layer.borderWidth = 1
		searchBar.backgroundColor = Color.white
		searchBar.translucent = false
		searchBar.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		searchBar.setImage(UIImage(named: "SearchSmall"), forSearchBarIcon: .Search, state: .Normal)
		addSubview(searchBar)

		if let string = searchBar.placeholder {
			let placeholder = NSAttributedString(string: string, attributes: [
				NSForegroundColorAttributeName: Color.gray,
				NSFontAttributeName: Font.sansSerif(size: .Small)
			])
			UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).attributedPlaceholder = placeholder
		}

		topBorderView.backgroundColor = Color.searchBarBorder
		addSubview(topBorderView)

		bottomBorderView.backgroundColor = Color.searchBarBorder
		addSubview(bottomBorderView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func addSubview(view: UIView) {
		super.addSubview(view)

		// UISearchController removes this view and then adds it back. Move it to the back when it's added so it stays
		// below the borders.
		if view == searchBar {
			sendSubviewToBack(view)
		}
	}

	override func sizeThatFits(size: CGSize) -> CGSize {
		return CGSize(width: size.width, height: 44)
	}

	override func layoutSubviews() {
		let borderHeight = 1 / traitCollection.displayScale

		topBorderView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: borderHeight)
		bottomBorderView.frame = CGRect(x: 0, y: bounds.height - borderHeight, width: bounds.width, height: borderHeight)
	}

	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setNeedsLayout()
	}
}
