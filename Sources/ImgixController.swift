//
//  ImgixController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

struct ImgixController {
	static func signURL(URL: NSURL, parameters: [NSURLQueryItem]?) -> NSURL? {
		let defaultParameters = [
			NSURLQueryItem(name: "fm", value: "jpg"),
			NSURLQueryItem(name: "q", value: "80")
		]

		// Uploaded image
		let uploadPrefix = "https://canvas-files-prod.s3.amazonaws.com/uploads/"
		if URL.absoluteString.hasPrefix(uploadPrefix) {
			let imgix = Imgix(host: config.imgixUploadHost, secret: config.imgixUploadSecret, defaultParameters: defaultParameters)
			let path = (URL.absoluteString as NSString).substringFromIndex((uploadPrefix as NSString).length)
			return imgix.signPath(path)
		}

		// Linked image
		let imgix = Imgix(host: config.imgixProxyHost, secret: config.imgixProxySecret, defaultParameters: defaultParameters)
		let path = URL.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())
		return path.flatMap { imgix.signPath($0) }
	}
}
