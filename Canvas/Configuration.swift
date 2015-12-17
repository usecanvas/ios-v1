//
//  Configuration.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import Camo

let baseURL = NSURL(string: "https://api.usecanvas.com/")!
let realtimeURL = NSURL(string: "wss://api.usecanvas.com/realtime")!
let longhouseURL = NSURL(string: "wss://presence.usecanvas.com/")!

let canvasClientID = "5QdrPgUUYQs2yvGLIUT5PL"

// Obfuscated client secret. The Camo secret is in the front-end website, so no need to obfuscate it here.
let canvasClientSecretPart4 = "aef895c32"
let canvasClientSecretPart2 = "f5bd59c7866e85"
let camoSecret = "a4a8767e694052184df6259377f751977a86513364a3e8d44fb71e16327bd937"
let canvasClientSecretPart1 = "60ff40c860274eb9afb6"
let canvasClientSecretPart3 = "97bdcc48ae89946"
let canvasClientSecret = "\(canvasClientSecretPart1)fb\(canvasClientSecretPart2)2e\(canvasClientSecretPart3)75\(canvasClientSecretPart4)"

let camoURL = NSURL(string: "https://camo.usecanvas.com/")!
