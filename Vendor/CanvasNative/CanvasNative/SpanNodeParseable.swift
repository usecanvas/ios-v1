//
//  SpanNodeParseable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/21/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

protocol SpanNodeParseable: SpanNode {
	static var regularExpression: NSRegularExpression { get }

	init?(match: NSTextCheckingResult)
}
