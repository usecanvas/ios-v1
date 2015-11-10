//
//  ShareController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import WebKit

enum Op {
	case Insert(location: UInt, string: String)
	case Delete(location: UInt, length: UInt)
	
	var range: NSRange {
		switch self {
		case .Insert(let location, _):
			return NSRange(location: Int(location), length: 0)
		case .Delete(let location, let length):
			return NSRange(location: Int(location), length: Int(length))
		}
	}
	
	init?(dictionary: [String: AnyObject]) {
		guard let type = dictionary["type"] as? String,
			location = dictionary["location"] as? UInt
		else { return nil }
		
		if let string = dictionary["text"] as? String where type == "insert" {
			self = .Insert(location: location, string: string)
			return
		}
		
		if let length = dictionary["length"] as? UInt where type == "delete" {
			self = .Delete(location: location, length: length)
			return
		}
		
		return nil
	}
}

class ShareController: NSObject {
	
	// MARK: - Properties
	
	let collectionID: String
	let canvasID: String
	weak var delegate: ShareControllerDelegate?
	
	private var webView: WKWebView!

	
	// MARK: - Initializers
	
	init(collectionID: String, canvasID: String) {
		self.collectionID = collectionID
		self.canvasID = canvasID
		
		super.init()
		
		let configuration = WKWebViewConfiguration()
		configuration.allowsAirPlayForMediaPlayback = false
		configuration.allowsInlineMediaPlayback = false
		configuration.allowsPictureInPictureMediaPlayback = false
		
		// Setup script handler
		let userContentController = WKUserContentController()
		userContentController.addScriptMessageHandler(self, name: "share")
		
		// Connect
		let js = "window.connectToCanvas('\(collectionID)', '\(canvasID)');"
		userContentController.addUserScript(WKUserScript(source: js, injectionTime: .AtDocumentEnd, forMainFrameOnly: true))
		configuration.userContentController = userContentController
		
		// Load file
		webView = WKWebView(frame: .zero, configuration: configuration)
		let fileURL = NSBundle.mainBundle().URLForResource("editor", withExtension: "html")!
		webView.loadFileURL(fileURL, allowingReadAccessToURL: fileURL)
	}
}


extension ShareController: WKScriptMessageHandler {
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
		guard let dictionary = message.body as? [String: AnyObject] else { return }
		
		if let dict = dictionary["op"] as? [String: AnyObject], op = Op(dictionary: dict) {
			delegate?.shareController(self, didReceiveOp: op)
		} else if let snapshot = dictionary["snapshot"] as? String {
			delegate?.shareController(self, didReceiveSnapshot: snapshot)
		}
	}
}


protocol ShareControllerDelegate: class {
	func shareController(controller: ShareController, didReceiveSnapshot text: String)
	func shareController(controller: ShareController, didReceiveOp op: Op)
}
