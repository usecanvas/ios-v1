//
//  NSDate+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSDate {
	var briefTimeAgoInWords: String {
		// Seconds
		let seconds = abs(timeIntervalSinceNow)
		if seconds < 60 {
			return "\(UInt(seconds))s"
		}

		// Minutes
		let minutes = seconds / 60
		if minutes < 60 {
			return "\(UInt(minutes))m"
		}

		// Hours
		let hours = minutes / 60
		if hours < 24 {
			return "\(UInt(hours))m"
		}

		// Days
		let days = hours / 24
		if days < 365 {
			return "\(UInt(days))m"
		}

		// Years
		let years = days / 365
		return "\(UInt(years))y"
	}
}