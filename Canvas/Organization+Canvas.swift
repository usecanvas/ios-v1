//
//  Organization+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit
import Static

extension Organization {
	var row: Row {
		return  Row(
			text: name,
			accessory: .DisclosureIndicator,
			cellClass: OrganizationCell.self
		)
	}
}
