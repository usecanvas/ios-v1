//
//  APIClient+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 7/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasCore
import CanvasKit

extension CanvasCore.APIClient {
	convenience init(account: Account) {
		self.init(account: account, config: config)
	}
}
