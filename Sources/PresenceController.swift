//
//  PresenceController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasKit
import SocketRocket

class PresenceController: NSObject, Accountable {

	// MARK: - Types

	enum State: Int {
		case Connecting, Open, Closing, Closed, Disconnected
	}

	private struct Connection {
		let canvasID: String
		let connectionID: String
		var cursor: Cursor?

		init(canvasID: String, connectionID: String = NSUUID().UUIDString) {
			self.canvasID = canvasID
			self.connectionID = connectionID
		}
	}

	private struct Cursor {
		/// Index of line on which the user's cursor begins
		var startLine: UInt

		/// Index of user's cursor start on `startLine`
		var start: UInt

		/// Index of line on which user's cursor ends
		var endLine: UInt

		/// Index of user's cursor end on `endLine`
		var end: UInt

//		init?(selectedRange: NSRange, string: String) {
//			let text = string as NSString
//			let bounds = NSRange(location: 0, length: text.length)
//
//			if NSMaxRange(selectedRange) > bounds.length {
//				return nil
//			}
//		}
	}


	// MARK: - Properties

	var account: Account

	var state: State {
		let readyState = socket?.readyState
		return readyState.flatMap { State(rawValue: $0.rawValue) } ?? .Disconnected
	}

	private var socket: SRWebSocket?
	private var connection: Connection?


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
	}


	// MARK: - Connecting

	func connect() {
		if socket != nil {
			return
		}

		let url = NSURL(string: "socket/websocket", relativeToURL: config.presenceURL)!
		let request = NSMutableURLRequest(URL: url)
		request.setValue("Bearer \(account.accessToken)", forHTTPHeaderField: "Authorization")

		let ws = SRWebSocket(URLRequest: request)
		ws.delegate = self
		ws.open()

		socket = ws
	}

	func disconnect() {
		socket?.close()
		socket = nil
	}


	// MARK: - Working with Canvases

	func setCanvas(canvasID canvasID: String) {
		let connection = Connection(canvasID: canvasID)
		self.connection = connection

		let payload = clientDescriptor(connectionID: connection.connectionID)

		socket?.send([
			"event": "phx_join",
			"topic": "presence:canvases:\(canvasID)",
			"payload": payload,
			"ref": "1"
		])
	}


	// MARK: - Private

	private func clientDescriptor(connectionID connectionID: String) -> [String: AnyObject] {
		return [
			"id": connectionID,
			"user": account.user.dictionary

			// TODO: Meta
		]
	}
}


extension PresenceController: SRWebSocketDelegate {
	func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
		print("[presence] message: \(message)")
	}

	func webSocketDidOpen(webSocket: SRWebSocket!) {
		print("[presence] did open")
	}

	func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
		print("[presence] error: \(error)")
	}

	func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
		print("[presence] close: \(code) \(reason)")
	}
}
