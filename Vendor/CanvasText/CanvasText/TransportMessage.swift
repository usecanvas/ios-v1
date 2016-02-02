//
//  TransportMessage.swift
//  CanvasText
//
//  Created by Sam Soffes on 2/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

enum TransportMessage {
	case Operation(operation: CanvasText.Operation)
	case Snapshot(content: String)
	case Error(message: String?, lineNumber: UInt?, columnNumber: UInt?)
	case Disconnect(message: String?)

	init?(dictionary: [String: AnyObject]) {
		guard let type = dictionary["type"] as? String else { return nil }

		if type == "operation", let dict = dictionary["operation"] as? [String: AnyObject], operation = CanvasText.Operation(dictionary: dict) {
			self = .Operation(operation: operation)
			return
		}

		if type == "snapshot", let content = dictionary["content"] as? String {
			self = .Snapshot(content: content)
			return
		}

		if type == "error" {
			self = .Error(message: dictionary["message"] as? String, lineNumber: dictionary["line_number"] as? UInt, columnNumber: dictionary["column_number"] as? UInt)
			return
		}

		if type == "disconnect" {
			self = .Disconnect(message: dictionary["message"] as? String)
			return
		}

		return nil
	}
}
