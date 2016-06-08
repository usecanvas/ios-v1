//
//  PresenceController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasKit
import Starscream

// TODO: Update meta
// TODO: Handle join
// TODO: Handle update meta
// TODO: Handle expired
class PresenceController: Accountable {

	// MARK: - Types

	private struct Connection {
		let canvasID: String
		let connectionID: String
		var cursor: Cursor?

		init(canvasID: String, connectionID: String = NSUUID().UUIDString.lowercaseString) {
			self.canvasID = canvasID
			self.connectionID = connectionID
		}
	}


	// MARK: - Properties

	var account: Account

	private var socket: WebSocket?
	private var connections = [String: Connection]()
	private var messageQueue = [[String: AnyObject]]()
	private var pingTimer: NSTimer?


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
	}

	deinit {
		for (_, connection) in connections {
			leave(canvasID: connection.canvasID)
		}
		
		socket?.disconnect()
	}


	// MARK: - Connecting

	private func connect() {
		if socket != nil {
			return
		}

		let url = NSURL(string: "socket/websocket", relativeToURL: config.presenceURL)!
		let ws = WebSocket(url: url)
		ws.origin = "https://usecanvas.com"
		ws.delegate = self
		ws.connect()

		socket = ws
	}

	func disconnect() {
		socket?.disconnect()
		socket = nil
	}


	// MARK: - Working with Canvases

	func join(canvasID canvasID: String) {
		let connection = Connection(canvasID: canvasID)
		let payload = clientDescriptor(connectionID: connection.connectionID)

		sendMessage([
			"event": "phx_join",
			"topic": "presence:canvases:\(canvasID)",
			"payload": payload,
			"ref": "1"
		])

		connections[canvasID] = connection
	}

	func leave(canvasID canvasID: String) {
		guard let connection = connections[canvasID] else { return }

		sendMessage([
			"event": "phx_leave",
			"topic": "presence:canvases:\(connection.canvasID)",
			"payload": [:],
			"ref": "4"
		])

		connections.removeValueForKey(canvasID)
	}


	// MARK: - Private

	private func sendMessage(message: [String: AnyObject]) {
		if let socket = socket where socket.isConnected {
			if let data = try? NSJSONSerialization.dataWithJSONObject(message, options: []) {
				print("[presence] send: \(message)")
				socket.writeData(data)
			}
		} else {
			connect()
			messageQueue.append(message)
		}
	}

	private func clientDescriptor(connectionID connectionID: String) -> [String: AnyObject] {
		return [
			"id": connectionID,
			"user": account.user.dictionary,

			// TODO: Meta
			"meta": [:]
		]
	}

	@objc private func ping() {
		for (_, connection) in connections {
			sendMessage([
				"event": "ping",
				"topic": "presence:canvases:\(connection.canvasID)",
				"payload": [:],
				"ref": "2"
			])
		}
	}
}


extension PresenceController: WebSocketDelegate {
	func websocketDidConnect(socket: WebSocket) {
		print("[presence] did open")

		for message in messageQueue {
			if let data = try? NSJSONSerialization.dataWithJSONObject(message, options: []) {
				print("[presence] send: \(message)")
				socket.writeData(data)
			}
		}

		messageQueue.removeAll()

		let timer = NSTimer(timeInterval: 20, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
		pingTimer = timer
	}

	func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
		print("[presence] did disconnect: \(error)")

		pingTimer?.invalidate()
		pingTimer = nil
	}

	func websocketDidReceiveMessage(socket: WebSocket, text: String) {
		print("[presence] did receive message: \(text)")
	}

	func websocketDidReceiveData(socket: WebSocket, data: NSData) {
		print("[presence] did receive data: \(data)")
	}
}
