//
//  Box.swift
//  Canvas
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

class Box<T> {
	
	// MARK: - Properties
	
	let value: T
	
	
	// MARK: - Initializers
	
	init(_ value: T) {
		self.value = value
	}
}
