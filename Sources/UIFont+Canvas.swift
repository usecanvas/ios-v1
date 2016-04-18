//
//  UIFont+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 12/16/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension UIFont {
	var fontWithMonospaceNumbers: UIFont {
		let fontDescriptor = UIFontDescriptor(name: fontName, size: pointSize).fontDescriptorByAddingAttributes([
			UIFontDescriptorFeatureSettingsAttribute: [
				[
					UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
					UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
				]
			]
		])

		return UIFont(descriptor: fontDescriptor, size: pointSize)
	}
}
