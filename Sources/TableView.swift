//
//  TableView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class TableView: UITableView {
	override func tintColorDidChange() {
		super.tintColorDidChange()

		if style != .Grouped {
			return
		}

		backgroundColor = tintAdjustmentMode == .Dimmed ? Swatch.groupedTableBackground.desaturated : Swatch.groupedTableBackground
	}
}
