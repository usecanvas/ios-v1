//
//  Font.swift
//  Canvas
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

struct Font {

	enum Weight {
		case Regular
		case Bold

		var weight: CGFloat {
			switch self {
			case .Regular: return UIFontWeightRegular
			case .Bold: return UIFontWeightMedium
			}
		}
	}

	enum Style {
		case Regular
		case Italic
	}

	enum Size: UInt {
		case Small = 14
		case Subtitle = 16
		case Body = 18

		var pointSize: CGFloat {
			return CGFloat(rawValue)
		}
	}

	static func sansSerif(weight weight: Weight = .Regular, style: Style = .Regular, size: Size = .Body) -> UIFont! {
		if style == .Italic {
			// TODO: Weight is currently ignored for italic
			return .italicSystemFontOfSize(size.pointSize)
		}

		return .systemFontOfSize(size.pointSize, weight: weight.weight)
	}
}
