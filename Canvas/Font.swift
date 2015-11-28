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
			case .Bold: return UIFontWeightSemibold
			}
		}
	}

	enum Size: UInt {
		case Body = 18

		var pointSize: CGFloat {
			return CGFloat(rawValue)
		}
	}

	static func sansSerif(weight weight: Weight = .Regular, size: Size = .Body) -> UIFont! {
		return .systemFontOfSize(size.pointSize, weight: weight.weight)
	}

	// TODO: Remove this
	static func sansSerif(weight weight: Weight = .Regular, pointSize: CGFloat) -> UIFont! {
		return .systemFontOfSize(pointSize, weight: weight.weight)
	}
}
