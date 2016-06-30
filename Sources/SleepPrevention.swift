//
//  SleepPrevention.swift
//  Canvas
//
//  Created by Sam Soffes on 6/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

enum SleepPrevention: String, CustomStringConvertible {
	case never
	case whilePluggedIn
	case always

	var description: String {
		switch self {
		case .never: return "System Default"
		case .whilePluggedIn: return "While Plugged In"
		case .always: return "Never Sleep"
		}
	}

	static let all: [SleepPrevention] = [.never, .whilePluggedIn, .always]

	static let defaultsKey = "PreventSleep"

	static var currentPreference: SleepPrevention {
		guard let string = NSUserDefaults.standardUserDefaults().stringForKey(defaultsKey) else { return .whilePluggedIn }
		return SleepPrevention(rawValue: string) ?? .whilePluggedIn
	}

	static func select(preference: SleepPrevention) {
		NSUserDefaults.standardUserDefaults().setObject(preference.rawValue, forKey: defaultsKey)
	}
}
