//
//  APIClient.swift
//  Canvas
//
//  Created by Sam Soffes on 7/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit
import CanvasCore

final class APIClient: CanvasKit.APIClient {
	convenience init(account: Account) {
		self.init(accessToken: account.accessToken, baseURL: config.environment.apiURL)
	}

	override func shouldComplete<T>(request request: NSURLRequest, response: NSHTTPURLResponse?, data: NSData?, error: NSError?, completion: (Result<T> -> Void)?) -> Bool {
		// TODO: Remove 400 once the API updates
		if response?.statusCode == 400 || response?.statusCode == 401 {
			dispatch_async(dispatch_get_main_queue()) {
				AccountController.sharedController.currentAccount = nil
			}
			return false
		}

		return super.shouldComplete(request: request, response: response, data: data, error: error, completion: completion)
	}
}
