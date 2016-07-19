//
//  DestructiveValueCell.swift
//  Canvas
//
//  Created by Sam Soffes on 7/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore

final class DestructiveButtonCell: UITableViewCell, CellType {
	override func tintColorDidChange() {
		textLabel?.textColor = tintAdjustmentMode == .Dimmed ? tintColor: Swatch.destructive
		imageView?.tintColor = textLabel?.textColor
	}
}
