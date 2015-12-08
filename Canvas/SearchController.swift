//
//  SearchController.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Foundation
import CanvasKit
import SSKeychain
import AlgoliaSearch

/// Object for coordinating searches
class SearchController {

	// MARK: - Properties

	let account: Account
	let collection: Collection

	/// Results are delivered to this callback
	var callback: ([Canvas] -> Void)?

	private let semaphore = dispatch_semaphore_create(0)
	private var searchCredential: SearchCredential?

	private var nextQuery: String? {
		didSet {
			query()
		}
	}


	// MARK: - Initializers

	init(account: Account, collection: Collection) {
		self.account = account
		self.collection = collection
		fetchSearchToken()
	}


	// MARK: - Search

	func search(query: String) {
		nextQuery = query.isEmpty ? nil : query
	}


	// MARK: - Private

	private func fetchSearchToken() {
		// Get from keychain
		let keychainService = "CanvasSearch"
		let keychainAccount = collection.ID
		if let data = SSKeychain.passwordDataForService(keychainService, account: keychainAccount),
			raw = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
			dictionary = raw as? JSONDictionary,
			credential = SearchCredential(dictionary: dictionary) {

				searchCredential = credential
				dispatch_semaphore_signal(semaphore)
				return
		}

		// Fetch from API
		let client = APIClient(accessToken: account.accessToken)
		client.getCollectionSearchCredential(collection: collection) { [weak self] result in
			switch result {
			case .Success(let credential):
				// Cache in the keychain
				if let data = try? NSJSONSerialization.dataWithJSONObject(credential.dictionary, options: []) {
					SSKeychain.setPasswordData(data, forService: keychainService, account: keychainAccount)
				}

				self?.searchCredential = credential
				if let semaphore = self?.semaphore {
					dispatch_semaphore_signal(semaphore)
				}
			default: print("Failed to get search token")
			}
		}
	}

	private func query() {
		guard nextQuery != nil else { return }

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { [weak self] in
			guard let semaphore = self?.semaphore else { return }

			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

			guard let credential = self?.searchCredential,
				collectionID = self?.collection.ID,
				text = self?.nextQuery
			else {
				dispatch_semaphore_signal(semaphore)
				return
			}

			self?.nextQuery = nil

			// Setup client
			let search = Client(appID: credential.applicationID, apiKey: credential.searchKey)

			// Get index
			let index = search.getIndex("prod_canvases")

			// Construct query
			let query = Query(query: text)
			query.facetFilters = [
				"collection_id:\(collectionID)"
			]

			// Search index
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = true
			}

			index.search(query) { content, error in
				dispatch_async(dispatch_get_main_queue()) {
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				}

				guard let content = content,
					hits = content["hits"] as? [JSONDictionary]
				else { return }

				let canvases = hits.flatMap { Canvas(dictionary: $0) }
				self?.callback?(canvases)
				dispatch_semaphore_signal(semaphore)
			}
		}
	}
}
