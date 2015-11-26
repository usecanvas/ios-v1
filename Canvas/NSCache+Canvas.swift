//
//  NSCache.swift
//  Canvas
//
//  Created by Sam Soffes on 11/26/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSCache {
	subscript(key: AnyObject) -> AnyObject? {
		get {
			return objectForKey(key)
		}

		set(object) {
			if let object = object {
				setObject(object, forKey: key)
			} else {
				removeObjectForKey(key)
			}
		}
	}
}
