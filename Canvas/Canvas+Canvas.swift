//
//  Canvas+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit
import Static

extension Canvas {
	var row: Row {
		return Row(
			text: displayTitle,
			detailText: summary,
			accessory: .DisclosureIndicator,
			cellClass: CanvasCell.self,
			context: ["canvas": self]
		)
	}
}
