//
//  NSProcessInfo+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 7/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSProcessInfo {
	var isSnapshotting: Bool {
		return arguments.contains("-snapshot")
	}
}
