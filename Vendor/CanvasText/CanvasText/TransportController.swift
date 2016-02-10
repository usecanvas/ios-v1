//
//  TransportController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import WebKit

protocol TransportControllerDelegate: class {
	func transportController(controller: TransportController, didReceiveSnapshot text: String)
	func transportController(controller: TransportController, didReceiveOperation operation: Operation)
	func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?)
	func transportController(controller: TransportController, didDisconnectWithErrorMessage errorMessage: String?)
}


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

		reload()
	}


	// MARK: - Connecting

	func reload() {
		let bundle = NSBundle(forClass: TransportController.self)
		guard let editorPath = bundle.pathForResource("editor", ofType: "html"),
			editor = try? String(contentsOfFile: editorPath, encoding: NSUTF8StringEncoding)
		else { return }

		webView.loadHTMLString(editor, baseURL: serverURL)
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


extension TransportController: WKScriptMessageHandler {
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage scriptMessage: WKScriptMessage) {
		guard let dictionary = scriptMessage.body as? [String: AnyObject],
			message = TransportMessage(dictionary: dictionary)
		else {
			print("[TransportController] Unknown message: \(scriptMessage.body)")
			return
		}

		switch message {
		case .Operation(let operation):
			delegate?.transportController(self, didReceiveOperation: operation)
		case .Snapshot(let content):
			delegate?.transportController(self, didReceiveSnapshot: content)
		case .Disconnect(let errorMessage):
			delegate?.transportController(self, didDisconnectWithErrorMessage: errorMessage)
		case .Error(let errorMessage, let lineNumber, let columnNumber):
			delegate?.transportController(self, didReceiveWebErrorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber)
		}
	}
}
