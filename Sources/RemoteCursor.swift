//
//  RemoteCursor.swift
//  Canvas
//
//  Created by Sam Soffes on 7/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

struct RemoteCursor: Hashable {
	let username: String
	var range: NSRange
	let color: UIColor

	var hashValue: Int {
		return username.lowercaseString.hashValue
	}
}


public func ==(lhs: RemoteCursor, rhs: RemoteCursor) -> Bool {
	return lhs.username.lowercaseString == rhs.username.lowercaseString
}
