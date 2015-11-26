//
//  Image.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Image: Attachable {

	// MARK: - Properties

	public var delimiterRange: NSRange

	public var ID: String
	public var size: CGSize
	public var URL: NSURL

	public var aspectRatio: CGFloat {
		return min(size.width, size.height) / max(size.width, size.height)
	}


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString("\(leadingDelimiter)image-", intoString: nil) {
			return nil
		}

		var json: NSString? = ""
		scanner.scanUpToString(trailingDelimiter, intoString: &json)

		if !scanner.scanString(trailingDelimiter, intoString: nil) {
			return nil
		}

		guard let data = json?.dataUsingEncoding(NSUTF8StringEncoding),
			raw = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
			dictionary = raw as? [String: AnyObject],
			ID = dictionary["ci"] as? String,
			width = dictionary["width"] as? UInt,
			height = dictionary["height"] as? UInt,
			URLString = dictionary["url"] as? String,
			URL = NSURL(string: URLString)
		else {
			return nil
		}

		self.ID = ID
		size = CGSize(width: Int(width), height: Int(height))
		self.URL = URL

		delimiterRange = NSRange(location: enclosingRange.location, length: enclosingRange.length - 1)
	}
}
