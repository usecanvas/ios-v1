//
//  ImagesController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

class ImagesController {

	// MARK: - Types

	typealias Completion = (node: Image, image: UIImage?) -> Void


	// MARK: - Properties

	let session: NSURLSession

	private var downloading = [Image: [Completion]]()

	private let queue = dispatch_queue_create("com.usecanvas.canvas.imagescontroller", DISPATCH_QUEUE_SERIAL)

	/// The image ID is the key. The value is a UIImage object.
	private let cache: NSCache = {
		let cache = NSCache()
		cache.name = "ImagesController.cache"
		return cache
	}()

	static let sharedController = ImagesController()


	// MARK: - Initializers

	init(session: NSURLSession = NSURLSession.sharedSession()) {
		self.session = session
	}


	// MARK: - Accessing

	func image(node node: Image, completion: Completion) {
		if let image = cache[node.ID] as? UIImage {
			completion(node: node, image: image)
			return
		}

		coordinate {
			// Already downloading
			if var array = self.downloading[node] {
				array.append(completion)
				self.downloading[node] = array
				return
			}

			// Start download
			self.downloading[node] = [completion]

			let request = NSURLRequest(URL: node.URL)
			self.session.downloadTaskWithRequest(request) { [weak self] location, _, _ in
				self?.loadImage(location: location, node: node)
			}.resume()
		}
	}

	// MARK: - Private

	private func coordinate(block: dispatch_block_t) {
		dispatch_sync(queue, block)
	}

	private func loadImage(location location: NSURL?, node: Image) {
		let data = location.flatMap { NSData(contentsOfURL: $0) }
		let image = data.flatMap { UIImage(data: $0) }

		cache[node.ID] = image

		coordinate {
			if let completions = self.downloading[node] {
				for completion in completions {
					dispatch_async(dispatch_get_main_queue()) {
						completion(node: node, image: image)
					}
				}
				self.downloading[node] = nil
			}
			return
		}
	}
}
