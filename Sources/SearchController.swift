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

/// Object for coordinating searches
final class SearchController: NSObject {

	// MARK: - Properties

	let account: Account
	let organization: Organization

	/// Results are delivered to this callback
	var callback: ([Canvas] -> Void)?

	private let semaphore = dispatch_semaphore_create(0)

	private var nextQuery: String? {
		didSet {
			query()
		}
	}

	private let client: APIClient


	// MARK: - Initializers

	init(account: Account, organization: Organization) {
		self.account = account
		self.organization = organization
		client = APIClient(accessToken: account.accessToken)

		super.init()

		dispatch_semaphore_signal(semaphore)
	}


	// MARK: - Search

	func search(query: String) {
		nextQuery = query.isEmpty ? nil : query
	}


	// MARK: - Private

	private func query() {
		guard nextQuery != nil else { return }

		let organizationID = organization.ID

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { [weak self] in
			guard let semaphore = self?.semaphore else { return }

			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

			guard let query = self?.nextQuery, client = self?.client else {
				dispatch_semaphore_signal(semaphore)
				return
			}

			self?.nextQuery = nil

			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = true
			}

			let callback = self?.callback

			client.searchCanvases(organizationID: organizationID, query: query) { result in
				dispatch_async(dispatch_get_main_queue()) {
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false

					switch result {
					case .Success(let canvases): callback?(canvases)
					default: break
					}
				}

				dispatch_semaphore_signal(semaphore)
			}
		}
	}
}


extension SearchController: UISearchResultsUpdating {
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		guard let text = searchController.searchBar.text else { return }
		search(text)
	}
}
