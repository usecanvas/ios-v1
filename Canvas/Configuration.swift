//
//  Configuration.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

// Obfuscated client secret. The Camo secret is in the front-end website, so no need to obfuscate it here.
private let canvasClientSecretPart4 = "aef895c32"
private let canvasClientSecretPart2 = "f5bd59c7866e85"
private let _camoSecret = "a4a8767e694052184df6259377f751977a86513364a3e8d44fb71e16327bd937"
private let canvasClientSecretPart1 = "60ff40c860274eb9afb6"
private let canvasClientSecretPart3 = "97bdcc48ae89946"

struct Config {
	// MARK: - Canvas

	/// Canvas API base URL
	static let baseURL = NSURL(string: "https://api.usecanvas.com/v1/")!

	/// Canvase realtime base URL
	static let realtimeURL = NSURL(string: "wss://realtime.usecanvas.com/")!

	/// Canvas presence base URL
	static let presenceURL = NSURL(string: "wss://presence.usecanvas.com/")!

	/// Canvas client ID
	static let canvasClientID = "5QdrPgUUYQs2yvGLIUT5PL"

	/// Canvas client secret
	static let canvasClientSecret = "\(canvasClientSecretPart1)fb\(canvasClientSecretPart2)2e\(canvasClientSecretPart3)75\(canvasClientSecretPart4)"


	// MARK: - Camo

	/// Camo base URL
	static let camoURL = NSURL(string: "https://camo.usecanvas.com/")!

	/// Camo secret
	static let camoSecret = _camoSecret


	// MARK: - Analytics & Crash Reporting

	/// Rollbar post_client_item Access Token
	static let rollbarToken = "c8736fff4cc745f0b21187f0128ab233"

	/// Mixpanel token
	static let mixpanelToken = "447ae99e6cff699db67f168818c1dbf9"

	/// Hockey app identifier
	static let hockeyIdentifier = "0d558bb833514f31a4be3f9bfeafc43d"
}
