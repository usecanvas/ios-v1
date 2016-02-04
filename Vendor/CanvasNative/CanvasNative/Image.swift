//
//  Image.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Image: Attachable, Hashable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public let allowsReturnCompletion = false

	public var ID: String
	public var URL: NSURL
	public var size: CGSize?

	public var hashValue: Int {
		return ID.hashValue
	}


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		range = enclosingRange
		nativePrefixRange = NSRange(location: enclosingRange.location, length: enclosingRange.length - 1)
		
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// URL image
		if scanner.scanString("\(leadingNativePrefix)image\(trailingNativePrefix)", intoString: nil) {
			var urlString: NSString? = ""
			if !scanner.scanUpToString("\n", intoString: &urlString) {
				return nil
			}

			if let urlString = urlString as? String, URL = NSURL(string: urlString) {
				self.ID = urlString
				self.URL = URL
				self.size = nil
				return
			}

			return nil
		}

		// Uploaded image delimiter
		if !scanner.scanString("\(leadingNativePrefix)image-", intoString: nil) {
			return nil
		}

		var json: NSString? = ""
		scanner.scanUpToString(trailingNativePrefix, intoString: &json)

		if !scanner.scanString(trailingNativePrefix, intoString: nil) {
			return nil
		}

		guard let data = json?.dataUsingEncoding(NSUTF8StringEncoding),
			raw = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
			dictionary = raw as? [String: AnyObject],
			ID = dictionary["ci"] as? String,
			URLString = (dictionary["url"] as? String)?.stringByReplacingOccurrencesOfString(" ", withString: "%20"),
			URL = NSURL(string: URLString)
		else {
			return nil
		}

		self.ID = ID
		self.URL = URL

		if let width = dictionary["width"] as? UInt, height = dictionary["height"] as? UInt {
			size = CGSize(width: Int(width), height: Int(height))
		} else {
			size = nil
		}
	}
}


public func == (lhs: Image, rhs: Image) -> Bool {
	return lhs.ID == rhs.ID
}
