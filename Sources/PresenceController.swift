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

protocol PresenceObserver: NSObjectProtocol {
	func presenceDidChange(canvasID: String, users: [User])
}

// TODO: Update meta
// TODO: Handle multi remote connections
// TODO: Handle update meta
// TODO: Handle expired
class PresenceController: Accountable {

	// MARK: - Types

	private struct Connection {
		let canvasID: String
		let connectionID: String
		var cursor: Cursor?
		var users = [User]()

		init(canvasID: String, connectionID: String = NSUUID().UUIDString.lowercaseString) {
			self.canvasID = canvasID
			self.connectionID = connectionID
		}
	}


	// MARK: - Properties

	var account: Account

	var isConnected: Bool {
		return socket?.isConnected ?? false
	}

	private var socket: WebSocket? = nil
	private var connections = [String: Connection]()
	private var messageQueue = [JSONDictionary]()
	private var pingTimer: NSTimer?
	private var observers = NSMutableSet()


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		connect()
	}

	deinit {
		observers.removeAllObjects()
		disconnect()
	}


	// MARK: - Connecting

	func connect() {
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
		for (_, connection) in connections {
			leave(canvasID: connection.canvasID)
		}

		socket?.disconnect()
		socket = nil
	}


	// MARK: - Working with Canvases

	func join(canvasID canvasID: String) {
		let connection = Connection(canvasID: canvasID)
		let payload = clientDescriptor(connectionID: connection.connectionID)

		connections[canvasID] = connection

		sendMessage([
			"event": "phx_join",
			"topic": "presence:canvases:\(canvasID)",
			"payload": payload,
			"ref": "1"
		])
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


	// MARK: - Notifications

	func add(observer observer: PresenceObserver) {
		observers.addObject(observer)
	}

	func remove(observer observer: PresenceObserver) {
		observers.removeObject(observer)
	}


	// MARK: - Querying

	func users(canvasID canvasID: String) -> [User] {
		return connections[canvasID]?.users ?? []
	}


	// MARK: - Private

	private func sendMessage(message: JSONDictionary) {
		if let socket = socket where socket.isConnected {
			if let data = try? NSJSONSerialization.dataWithJSONObject(message, options: []) {
				socket.writeData(data)
			}
		} else {
			messageQueue.append(message)
			connect()
		}
	}

	private func clientDescriptor(connectionID connectionID: String) -> JSONDictionary {
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

	private func updateObservers(canvasID canvasID: String) {
		let users = connections[canvasID]?.users ?? []

		for observer in observers {
			guard let observer = observer as? PresenceObserver else { continue }
			observer.presenceDidChange(canvasID, users: users)
		}
	}
}


extension PresenceController: WebSocketDelegate {
	func websocketDidConnect(socket: WebSocket) {
		for message in messageQueue {
			if let data = try? NSJSONSerialization.dataWithJSONObject(message, options: []) {
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
		guard let data = text.dataUsingEncoding(NSUTF8StringEncoding),
			raw = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
			json = raw as? JSONDictionary,
			event = json["event"] as? String,
			topic = json["topic"] as? String,
			payload = json["payload"] as? JSONDictionary
		else { return }

		let canvasID = topic.stringByReplacingOccurrencesOfString("presence:canvases:", withString: "")
		guard var connection = connections[canvasID] else { return }

		// Join
		if event == "phx_reply", let response = payload["response"] as? JSONDictionary, clients = response["clients"] as? [JSONDictionary] {
			let users = clients.flatMap { ($0["user"] as? JSONDictionary).flatMap(User.init) }

			if !users.isEmpty {
				connection.users = users
				connections[canvasID] = connection
				updateObservers(canvasID: canvasID)
			}
		}

		// Remove join
		else if event == "remote_join", let dictionary = payload["user"] as? JSONDictionary, user = User.init(dictionary: dictionary) {
			var users = connection.users ?? []

			if users.indexOf({ $0.ID == user.ID }) == nil {
				users.append(user)
				connection.users = users
				connections[canvasID] = connection
				updateObservers(canvasID: canvasID)
			}
		}

		// Remove leave
		else if event == "remote_leave", let dictionary = payload["user"] as? JSONDictionary, userID = dictionary["id"] as? String {
			var users = connection.users ?? []

			if let index = users.indexOf({ $0.ID == userID }) {
				users.removeAtIndex(index)
				connection.users = users
				connections[canvasID] = connection
				updateObservers(canvasID: canvasID)
			}
		}
	}

	func websocketDidReceiveData(socket: WebSocket, data: NSData) {}
}
