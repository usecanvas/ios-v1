//
//  TransportController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import WebKit

class TransportController: NSObject {
	
	// MARK: - Properties

	let serverURL: NSURL
	private let accessToken: String
	let organizationID: String
	let canvasID: String
	weak var delegate: TransportControllerDelegate?
	var webView: WKWebView!
	
	
	// MARK: - Initializers
	
	init(serverURL: NSURL, accessToken: String, organizationID: String, canvasID: String) {
		self.serverURL = serverURL
		self.accessToken = accessToken
		self.organizationID = organizationID
		self.canvasID = canvasID
		
		super.init()
		
		let configuration = WKWebViewConfiguration()

		if #available(iOSApplicationExtension 9.0, *) {
		    configuration.allowsAirPlayForMediaPlayback = false
		}

		#if !os(OSX)
			configuration.allowsInlineMediaPlayback = false

			if #available(iOSApplicationExtension 9.0, *) {
				configuration.allowsPictureInPictureMediaPlayback = false
			}
		#endif

		// Setup script handler
		let userContentController = WKUserContentController()
		userContentController.addScriptMessageHandler(self, name: "share")
		
		// Connect
		let js = "Canvas.connect('\(serverURL.absoluteString)', '\(accessToken)', '\(organizationID)', '\(canvasID)');"
		userContentController.addUserScript(WKUserScript(source: js, injectionTime: .AtDocumentEnd, forMainFrameOnly: true))
		configuration.userContentController = userContentController
		
		// Load file
		webView = WKWebView(frame: .zero, configuration: configuration)

		#if !os(OSX)
			webView.scrollView.scrollsToTop = false
		#endif
	}


	// MARK: - Connecting

	func reload() {
		let bundle = NSBundle(forClass: TransportController.self)
		guard let sharePath = bundle.pathForResource("share", ofType: "js"),
			shareJS = try? String(contentsOfFile: sharePath, encoding: NSUTF8StringEncoding),
			editorPath = bundle.pathForResource("editor", ofType: "js"),
			editorJS = try? String(contentsOfFile: editorPath, encoding: NSUTF8StringEncoding),
			rollbarPath = bundle.pathForResource("rollbar", ofType: "js"),
			rollbarJS = try? String(contentsOfFile: rollbarPath, encoding: NSUTF8StringEncoding),
			templatePath = bundle.pathForResource("template", ofType: "html"),
			template = try? String(contentsOfFile: templatePath, encoding: NSUTF8StringEncoding)
		else { return }

		let javaScript = rollbarJS + shareJS + editorJS
		let html = NSString(format: template, javaScript) as String
		webView.loadHTMLString(html, baseURL: NSURL(string: "https://ios.usecanvas.com/")!)
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


protocol TransportControllerDelegate: class {
	func transportController(controller: TransportController, didReceiveSnapshot text: String)
	func transportController(controller: TransportController, didReceiveOperation operation: Operation)
}


extension TransportController: WKScriptMessageHandler {
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
		guard let dictionary = message.body as? [String: AnyObject] else { return }
		
		if let dict = dictionary["op"] as? [String: AnyObject], operation = Operation(dictionary: dict) {
			delegate?.transportController(self, didReceiveOperation: operation)
		} else if let snapshot = dictionary["snapshot"] as? String {
			delegate?.transportController(self, didReceiveSnapshot: snapshot)
		} else {
			print(dictionary)
		}
	}
}

