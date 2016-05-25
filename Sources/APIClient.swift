//
//  APIClient.swift
//  Canvas
//
//  Created by Sam Soffes on 5/24/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit

class APIClient: CanvasKit.APIClient {
	convenience init(account: Account) {
		self.init(accessToken: account.accessToken, baseURL: config.baseURL)
	}

	override func shouldComplete<T>(request request: NSURLRequest, response: NSHTTPURLResponse?, data: NSData?, error: NSError?, completion: Result<T> -> Void) -> Bool {
		if response?.statusCode == 401 {
			dispatch_async(dispatch_get_main_queue()) {
				AccountController.sharedController.currentAccount = nil
			}
			return false
		}

		return super.shouldComplete(request: request, response: response, data: data, error: error, completion: completion)
	}
}
