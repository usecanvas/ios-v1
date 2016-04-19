//
//  Configuration.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

// Obfuscated client secret
private let canvasClientSecretPart4 = "aef895c32"
private let canvasClientSecretPart2 = "f5bd59c7866e85"
private let canvasClientSecretPart1 = "60ff40c860274eb9afb6"
private let canvasClientSecretPart3 = "97bdcc48ae89946"


private enum Environment: String {
	case Development
	case Staging
	case Production

	var baseURL: NSURL {
		switch self {
		case .Development: return NSURL(string: "http://localhost:5001/v1/")!
		case .Staging: return NSURL(string: "https://canvas-api-staging.herokuapp.com/v1/")!
		case .Production: return NSURL(string: "https://api.usecanvas.com/v1/")!
		}
	}

	var realtimeURL: NSURL {
		switch self {
		case .Development: return NSURL(string: "ws://localhost:5002/")!
		case .Staging: return NSURL(string: "wss://canvas-realtime-staging.herokuapp.com/")!
		case .Production: return NSURL(string: "wss://realtime.usecanvas.com/")!
		}
	}

	var presenceURL: NSURL {
		switch self {
		case .Development: return NSURL(string: "ws://localhost:5003/")!
		case .Staging: return NSURL(string: "wss://canvas-presence-staging.herokuapp.com/")!
		case .Production: return NSURL(string: "wss://presence.usecanvas.com/")!
		}
	}
}


struct Configuration {

	// MARK: - Canvas

	/// Canvas API base URL
	let baseURL: NSURL

	/// Canvase realtime base URL
	let realtimeURL: NSURL

	/// Canvas presence base URL
	let presenceURL: NSURL

	/// Canvas client ID
	let canvasClientID = "5QdrPgUUYQs2yvGLIUT5PL"

	/// Canvas client secret
	let canvasClientSecret = "\(canvasClientSecretPart1)fb\(canvasClientSecretPart2)2e\(canvasClientSecretPart3)75\(canvasClientSecretPart4)"


	// MARK: - Analytics & Crash Reporting

	/// Mixpanel token
	let mixpanelToken = "447ae99e6cff699db67f168818c1dbf9"

	/// Hockey app identifier
	let hockeyIdentifier = "0d558bb833514f31a4be3f9bfeafc43d"


	// MARK: - Initializers

	private init(_ environment: Environment) {
		baseURL = environment.baseURL
		realtimeURL = environment.realtimeURL
		presenceURL = environment.presenceURL
	}
}

/// Setup configuration with the desired environment
let config = Configuration(.Production)
