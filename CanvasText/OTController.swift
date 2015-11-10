//
//  OTController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import WebKit

class OTController: NSObject {
	
	// MARK: - Properties
	
	let collectionID: String
	let canvasID: String
	let serverURL: NSURL
	weak var delegate: OTControllerDelegate?
	
	private var webView: WKWebView!
	
	
	// MARK: - Initializers
	
	init(collectionID: String, canvasID: String, serverURL: NSURL = NSURL(string: "ws://localhost:5001/realtime")!) {
		self.collectionID = collectionID
		self.canvasID = canvasID
		self.serverURL = serverURL
		
		super.init()
		
		let configuration = WKWebViewConfiguration()
		configuration.allowsAirPlayForMediaPlayback = false
		configuration.allowsInlineMediaPlayback = false
		configuration.allowsPictureInPictureMediaPlayback = false
		
		// Setup script handler
		let userContentController = WKUserContentController()
		userContentController.addScriptMessageHandler(self, name: "share")
		
		// Connect
		let js = "Canvas.connect('\(serverURL.absoluteString)', '\(collectionID)', '\(canvasID)');"
		userContentController.addUserScript(WKUserScript(source: js, injectionTime: .AtDocumentEnd, forMainFrameOnly: true))
		configuration.userContentController = userContentController
		
		// Load file
		webView = WKWebView(frame: .zero, configuration: configuration)
		let fileURL = NSBundle(forClass: OTController.self).URLForResource("editor", withExtension: "html")!
		webView.loadFileURL(fileURL, allowingReadAccessToURL: fileURL)
	}
	
	
	// MARK: - Operations
	
	func submitOperation(operation: Operation) {
		switch operation {
		case .Insert(let location, let string): insert(location: location, string: string)
		case .Remove(let location, let length): remove(location: location, length: length)
		}
	}
	
	
	// MARK: - Private
	
	private func insert(location location: UInt, string: String) {
		guard let data = try? NSJSONSerialization.dataWithJSONObject([string], options: []),
			json = String(data: data, encoding: NSUTF8StringEncoding)
			else { return }
		
		webView.evaluateJavaScript("Canvas.insert(\(location), \(json)[0]);", completionHandler: nil)
	}
	
	private func remove(location location: UInt, length: UInt) {
		webView.evaluateJavaScript("Canvas.remove(\(location), \(length));", completionHandler: nil)
	}
}


protocol OTControllerDelegate: class {
	func otController(controller: OTController, didReceiveSnapshot text: String)
	func otController(controller: OTController, didReceiveOperation operation: Operation)
}


extension OTController: WKScriptMessageHandler {
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
		guard let dictionary = message.body as? [String: AnyObject] else { return }
		
		if let dict = dictionary["op"] as? [String: AnyObject], operation = Operation(dictionary: dict) {
			delegate?.otController(self, didReceiveOperation: operation)
		} else if let snapshot = dictionary["snapshot"] as? String {
			delegate?.otController(self, didReceiveSnapshot: snapshot)
		}
	}
}
