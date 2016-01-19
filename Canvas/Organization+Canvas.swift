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
			return UIColor(red: 0.584, green: 0.004, blue: 1, alpha: 1)
		}

		if name == "test" {
			return UIColor(red: 1, green: 0.231, blue: 0.412, alpha: 1)
		}

		if name == "family" {
			return UIColor(red: 0, green: 0.510, blue: 0, alpha: 1)
		}

		if name == "spec" {
			return UIColor(red: 0.494, green: 0.494, blue: 0.510, alpha: 1)
		}

		return Color.brand
	}

	var row: Row {
		// TODO: Localize
		var detailText = "\(membersCount) member"
		if membersCount != 1 {
			detailText += "s"
		}

		return  Row(
			text: name,
			detailText: detailText,
			context: [
				"organization": self
			],
			cellClass: OrganizationCell.self
		)
	}
}
