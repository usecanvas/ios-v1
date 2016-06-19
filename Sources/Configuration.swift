//
//  Configuration.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CanvasCore

private let canvasClientID = "5QdrPgUUYQs2yvGLIUT5PL"

private let canvasClientSecretPart4 = "aef895c32"
private let canvasClientSecretPart2 = "f5bd59c7866e85"
private let canvasClientSecretPart1 = "60ff40c860274eb9afb6"
private let canvasClientSecretPart3 = "97bdcc48ae89946"
private let canvasClientSecret = "\(canvasClientSecretPart1)fb\(canvasClientSecretPart2)2e\(canvasClientSecretPart3)75\(canvasClientSecretPart4)"

let config = Configuration(environment: .production, canvasClientID: canvasClientID, canvasClientSecret: canvasClientSecret)
