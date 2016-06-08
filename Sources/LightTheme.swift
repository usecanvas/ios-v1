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

	// MARK: - Properties

	var tintColor: X.Color

	let backgroundColor = Color.white
	let foregroundColor = Color.black
	let placeholderColor = Color.lightGray

	let bulletColor = Color.gray
	let uncheckedCheckboxColor = Color.gray
	let orderedListItemNumberColor = Color.gray
	let horizontalRuleColor = Color.gray

	let codeColor = Color.gray
	let codeBlockBackgroundColor = Color.extraLightGray
	let codeBlockLineNumberColor = Color.lightGray
	let codeBlockLineNumberBackgroundColor = Color.lightGray

	let blockquoteColor = Color.gray
	let blockquoteBorderColor = Color.lightGray

	let commentBackgroundColor = Color.comment

	let placeholderImageColor = Color.gray
	let placeholderImageBackgroundColor = Color.extraLightGray

	let foldedColor = Color.gray
	let strikethroughColor = Color.gray
	let linkURLColor = Color.gray
	let codeSpanColor = Color.gray
	let codeSpanBackgroundColor = Color.extraLightGray


	// MARK: - Initializers

	init(tintColor: X.Color) {
		self.tintColor = tintColor
	}
}
