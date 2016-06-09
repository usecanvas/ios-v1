//
//  PresenceController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import Starscream

protocol PresenceObserver: NSObjectProtocol {
	func presenceDidChange(canvasID: String)
}

// TODO: Update meta
// TODO: Handle update meta
// TODO: Handle expired
class PresenceController: Accountable {

	// MARK: - Types

	private struct Client {
		let ID: String
		let user: User
		var cursor: Cursor?

		init?(dictionary: JSONDictionary) {
			guard let ID = dictionary["id"] as? String,
				user = (dictionary["user"] as? JSONDictionary).flatMap(User.init)
			else { return nil }

			self.ID = ID
			self.user = user
		}
	}

	private struct Connection {
		let canvasID: String
		let connectionID: String
		var cursor: Cursor?
		var clients = [Client]()

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

		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
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

		connections[canvasID] = connection

		sendJoinMessage(connection)
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
		guard let connection = connections[canvasID] else { return [] }

		var seen = Set<String>()
		var users = [User]()

		for client in connection.clients {
			if seen.contains(client.user.ID) {
				continue
			}

			seen.insert(client.user.ID)
			users.append(client.user)
		}

		return users
	}


	// MARK: - Private

	@objc private func applicationWillEnterForeground() {
		if connections.isEmpty {
			return
		}

		connect()
		connections.values.forEach(sendJoinMessage)
		setupPingTimer()
	}

	@objc private func applicationDidEnterBackground() {
		pingTimer?.invalidate()
		pingTimer = nil

		socket?.disconnect()
		socket = nil
	}

	private func sendJoinMessage(connection: Connection) {
		let payload = clientDescriptor(connectionID: connection.connectionID)

		sendMessage([
			"event": "phx_join",
			"topic": "presence:canvases:\(connection.canvasID)",
			"payload": payload,
			"ref": "1"
		])
	}

	private func setupPingTimer() {
		if pingTimer != nil {
			return
		}

		let timer = NSTimer(timeInterval: 20, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
		timer.tolerance = 10
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
		pingTimer = timer
	}

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
		for observer in observers {
			guard let observer = observer as? PresenceObserver else { continue }
			observer.presenceDidChange(canvasID)
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

		setupPingTimer()
	}

	func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
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
			let clients = clients.flatMap(Client.init)

			if !clients.isEmpty {
				connection.clients = clients
				connections[canvasID] = connection
				updateObservers(canvasID: canvasID)
			}
		}

		// Remove join
		else if event == "remote_join", let client = Client(dictionary: payload) {
			var clients = connection.clients ?? []
			let before = Set(clients.map { $0.user.ID })

			clients.append(client)
			connection.clients = clients
			connections[canvasID] = connection

			let after = Set(clients.map { $0.user.ID })
			if before != after {
				updateObservers(canvasID: canvasID)
			}
		}

		// Remove leave
		else if event == "remote_leave", let client = Client(dictionary: payload) {
			var clients = connection.clients ?? []
			let before = Set(clients.map { $0.user.ID })

			if let index = clients.indexOf({ $0.ID == client.ID }) {
				clients.removeAtIndex(index)
				connection.clients = clients
				connections[canvasID] = connection
			}

			let after = Set(clients.map { $0.user.ID })
			if before != after {
				updateObservers(canvasID: canvasID)
			}
		}
	}

	func websocketDidReceiveData(socket: WebSocket, data: NSData) {}
}
