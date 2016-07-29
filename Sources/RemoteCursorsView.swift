//
//  RemoteCursorsView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class RemoteCursorsView: UIView {

	// MARK: - Types

	struct RemoteCursor {
		let username: String
		let color: UIColor
		var range: NSRange
		var lineLayers = [CALayer]()

		let usernameLabel: UILabel = {
			let label = UILabel()
			label.font = .boldSystemFontOfSize(8)
			label.textColor = Swatch.black
			label.textAlignment = .Center
			return label
		}()

		var labelLayer: CALayer {
			return usernameLabel.layer
		}

		var layers: [CALayer] {
			return lineLayers + [labelLayer]
		}

		init(username: String, color: UIColor, range: NSRange) {
			self.username = username
			self.color = color
			self.range = range

			usernameLabel.backgroundColor = color
			usernameLabel.text = username
		}

	}


	// MARK: - Properties

	weak var textView: TextView?

	// TODO: Get colors from theme
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


	// MARK: - Updating

	func updateUser(username username: String, range: NSRange?) {
		let key = username.lowercaseString

		// If there's not a range, remove it from view
		guard let range = range else {
			if let cursor = cursors.removeValueForKey(key) {
				remove(cursor: cursor)
			}
			return
		}

		// Track this username
		usernames.insert(key)

		// Update an existing cursor
		let cursor: RemoteCursor
		if var cur = cursors[key] {
			if NSEqualRanges(cur.range, range) {
				return
			}

			cur.range = range
			cursor = cur
		}

		// Create a new cursor
		else {
			cursor = RemoteCursor(username: username, color: colors[usernames.count % colors.count], range: range)
		}

		// Layout updated cursor
		cursors[key] = cursor
		layout(cursor: cursor)
	}

	func layoutCursors() {
		cursors.values.forEach(layout)
	}


	// MARK: - Private

	private func remove(cursor cursor: RemoteCursor) {
		cursor.layers.forEach({ $0.removeFromSuperlayer() })
	}

	private func layout(cursor cursor: RemoteCursor) {
		var cursor = cursor
		cursor.lineLayers.forEach { $0.removeFromSuperlayer() }

		guard let textView = textView, rects = textView.rectsForRange(cursor.range) else {
			cursor.labelLayer.removeFromSuperlayer()
			return
		}

		// Setup line layers
		cursor.lineLayers = rects.map {
			let layer = CALayer()
			layer.backgroundColor = cursor.color.CGColor

			var rect = $0
			rect.origin.x += textView.contentInset.left
			rect.origin.y += textView.contentInset.top
			rect.size.width = max(2, rect.size.width)
			layer.frame = rect

			return layer
		}

		// Add the line layers to the view
		cursor.lineLayers.forEach(layer.addSublayer)

		// Add the label layer if needed
		if cursor.labelLayer.superlayer == nil {
			layer.addSublayer(cursor.labelLayer)
		}

		// Layout the label layer
		let firstLine = cursor.lineLayers[0]

		cursor.usernameLabel.sizeToFit()

		var size = cursor.usernameLabel.frame.size
		size.width += 4
		size.height += 4

		cursor.labelLayer.frame = CGRect(
			x: firstLine.frame.minX,
			y: firstLine.frame.minY - size.height,
			width: size.width,
			height: size.height
		)
	}
}
