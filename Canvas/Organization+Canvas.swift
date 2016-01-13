//
//  Organization+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import Static

extension Organization {
	var color: UIColor {
		if name == "DNGN" {
			return UIColor(red: 0.580, green: 0.459, blue: 0.878, alpha: 1)
		}

		if name == "test" {
			return UIColor.redColor()
		}

		return Color.brand
	}

	var row: Row {
		return  Row(
			text: name,
			accessory: .DisclosureIndicator,
			cellClass: OrganizationCell.self
		)
	}
}
