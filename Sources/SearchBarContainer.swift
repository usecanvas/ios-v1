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


	// MARK: - Initializers

	init(searchBar: UISearchBar) {
		self.searchBar = searchBar

		super.init(frame: searchBar.bounds)

		searchBar.barTintColor = .whiteColor()
		searchBar.layer.borderColor = UIColor.whiteColor().CGColor
		searchBar.layer.borderWidth = 1
		searchBar.backgroundColor = .whiteColor()
		searchBar.translucent = false
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		addSubview(searchBar)

		let topLine = UIView()
		topLine.translatesAutoresizingMaskIntoConstraints = false
		topLine.backgroundColor = UIColor(red: 0.784, green: 0.780, blue: 0.800, alpha: 1)
		addSubview(topLine)

		let bottomLine = UIView()
		bottomLine.translatesAutoresizingMaskIntoConstraints = false
		bottomLine.backgroundColor = topLine.backgroundColor
		addSubview(bottomLine)

		let scale = UIScreen.mainScreen().scale

		NSLayoutConstraint.activateConstraints([
			topLine.topAnchor.constraintEqualToAnchor(topAnchor),
			topLine.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			topLine.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			topLine.heightAnchor.constraintEqualToConstant(1 / scale),

			searchBar.topAnchor.constraintEqualToAnchor(topAnchor),
			searchBar.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			searchBar.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			searchBar.bottomAnchor.constraintEqualToAnchor(bottomAnchor),

			bottomLine.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
			bottomLine.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			bottomLine.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			bottomLine.heightAnchor.constraintEqualToConstant(1 / scale)
		])
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
}
