//
//  RemoteCursorsView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class RemoteCursorsView: UIView {

	// MARK: - Properties

	weak var textView: UITextView?

	private let colors = [
		UIColor(red: 250 / 255, green: 227 / 255, blue: 224 / 255, alpha: 1),
		UIColor(red: 250 / 255, green: 242 / 255, blue: 178 / 255, alpha: 1),
		UIColor(red: 236 / 255, green: 183 / 255, blue: 235 / 255, alpha: 1),
		UIColor(red: 1, green: 226 / 255, blue: 184 / 255, alpha: 1),
		UIColor(red: 196 / 255, green: 220 / 255, blue: 225 / 255, alpha: 1),
		UIColor(red: 1, green: 211 / 255, blue: 200 / 255, alpha: 1)
	]

	// Set of all lowercased usernames that we've seen. We use this to increment the color when a new user joins.
	private var usernames = Set<String>()

	// Mapping of lowercased usernames to a remote cursor model.
	private var cursors = [String: RemoteCursor]()

	private var cursorViews = [RemoteCursor: RemoteCursorView]()


	// MARK: - Updating

	func updateUser(username username: String, range: NSRange?) {
		let key = username.lowercaseString

		// If there's not a range, remove it from view
		guard let range = range else {
			cursors.removeValueForKey(key)
			return
		}

		// Track this username
		usernames.insert(key)

		// Update an existing cursor
		if var cursor = cursors[key] {
			if !NSEqualRanges(cursor.range, range) {
				cursor.range = range
				cursors[key] = cursor
			}
		}

		// Create a new cursor
		else {
			let cursor = RemoteCursor(username: username, range: range, color: colors[usernames.count % colors.count])
			cursors[key] = cursor
		}
	}

	func layout() {
		cursors.values.forEach(layoutCursorView)
	}


	// MARK: - Private

	private func addCursorView(cursor cursor: RemoteCursor) {

	}

	private func removeCursorView(cursor cursor: RemoteCursor) {

	}

	private func layoutCursorView(cursor cursor: RemoteCursor) {

	}
}
