//
//  AvatarsController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Cache
import X

final class AvatarsController {

	// MARK: - Types

	typealias Completion = (ID: String, image: UIImage?) -> Void


	// MARK: - Properties

	static let sharedController = AvatarsController()

	let session: NSURLSession

	private var downloading = [String: [Completion]]()

	private let queue = dispatch_queue_create("com.usecanvas.canvas.avatarscontroller", DISPATCH_QUEUE_SERIAL)

	private let memoryCache = MemoryCache<Image>()
	private let imageCache: MultiCache<Image>
	private let placeholderCache = MemoryCache<Image>()


	// MARK: - Initializers

	init(session: NSURLSession = NSURLSession.sharedSession()) {
		self.session = session

		var caches = [AnyCache(memoryCache)]

		// Setup disk cache
		if let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first {
			let directory = (cachesDirectory as NSString).stringByAppendingPathComponent("CanvasAvatars") as String

			if let diskCache = DiskCache<Image>(directory: directory) {
				caches.append(AnyCache(diskCache))
			}
		}

		imageCache = MultiCache(caches: caches)
	}


	// MARK: - Accessing

	func fetchImage(ID ID: String, URL: NSURL, completion: Completion) -> UIImage? {
		if let image = memoryCache[ID] {
			return image
		}

		imageCache.get(key: ID) { [weak self] image in
			if let image = image {
				dispatch_async(dispatch_get_main_queue()) {
					completion(ID: ID, image: image)
				}
				return
			}

			self?.coordinate { [weak self] in
				// Already downloading
				if var array = self?.downloading[ID] {
					array.append(completion)
					self?.downloading[ID] = array
					return
				}

				// Start download
				self?.downloading[ID] = [completion]

				let request = NSURLRequest(URL: URL)
				self?.session.downloadTaskWithRequest(request) { [weak self] location, _, _ in
					self?.loadImage(location: location, ID: ID)
				}.resume()
			}
		}

		return nil
	}


	// MARK: - Private

	private func coordinate(block: dispatch_block_t) {
		dispatch_sync(queue, block)
	}

	private func loadImage(location location: NSURL?, ID: String) {
		let data = location.flatMap { NSData(contentsOfURL: $0) }
		let image = data.flatMap { Image(data: $0) }

		if let image = image {
			imageCache.set(key: ID, value: image)
		}

		coordinate { [weak self] in
			if let image = image, completions = self?.downloading[ID] {
				for completion in completions {
					dispatch_async(dispatch_get_main_queue()) {
						completion(ID: ID, image: image)
					}
				}
			}

			self?.downloading[ID] = nil
		}
	}
}
