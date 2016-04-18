//
//  Environment.swift
//  Canvas
//
//  Created by Sam Soffes on 4/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

enum Environment: String {
	case Production
	case Staging

	var baseURL: NSURL {
		switch self {
		case .Production: return NSURL(string: "https://api.usecanvas.com/v1/")!
		case .Staging: return NSURL(string: "https://canvas-api-staging.herokuapp.com/v1/")!
		}
	}

	var realtimeURL: NSURL {
		switch self {
		case .Production: return NSURL(string: "wss://realtime.usecanvas.com/")!
		case .Staging: return NSURL(string: "wss://canvas-realtime-staging.herokuapp.com/")!
		}
	}

	var presenceURL: NSURL {
		switch self {
		case .Production: return NSURL(string: "wss://presence.usecanvas.com/")!
		case .Staging: return NSURL(string: "wss://canvas-presence-staging.herokuapp.com/")!
		}
	}
}
