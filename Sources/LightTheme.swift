//
//  LightTheme.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText
import X

struct LightTheme: Theme {

	// MARK: - Primary Colors

	let backgroundColor = Color.white
	let foregroundColor = Color.black
	var tintColor: X.Color


	// MARK: - Block Colors
	
	let titlePlaceholderColor = Color.lightGray
	let bulletColor = Color.gray
	let uncheckedCheckboxColor = Color.gray
	let orderedListItemNumberColor = Color.gray
	let codeColor = Color.gray
	let codeBlockBackgroundColor = Color.extraLightGray
	let codeBlockLineNumberColor = Color.lightGray
	let codeBlockLineNumberBackgroundColor = Color.lightGray
	let blockquoteColor = Color.gray
	let blockquoteBorderColor = Color.lightGray
	let headingOneColor = Color.black
	let headingTwoColor = Color.black
	let headingThreeColor = Color.black
	let headingFourColor = Color.black
	let headingFiveColor = Color.black
	let headingSixColor = Color.black
	let horizontalRuleColor = Color.gray
	let imagePlaceholderColor = Color.gray
	let imagePlaceholderBackgroundColor = Color.extraLightGray


	// MARK: - Span Colors

	let foldedColor = Color.gray
	let strikethroughColor = Color.gray
	let linkURLColor = Color.gray
	let codeSpanColor = Color.gray
	let codeSpanBackgroundColor = Color.extraLightGray
	let commentBackgroundColor = Color.comment


	// MARK: - Initializers

	init(tintColor: X.Color) {
		self.tintColor = tintColor
	}
}
