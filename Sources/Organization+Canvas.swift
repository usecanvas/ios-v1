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
