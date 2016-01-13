//
//  OrganizationsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit

class OrganizationsViewController: ModelsViewController, Accountable {

	// MARK: - Properties

	var account: Account


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		super.init(style: .Grouped)
		title = LocalizedString.OrganizationsTitle.string
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}



	// MARK: - UIResponder

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []
		commands += [
			UIKeyCommand(input: "Q", modifierFlags: [.Shift, .Command], action: "logOut:", discoverabilityTitle: LocalizedString.LogOutButton.string)
		]
		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rowHeight = 64
		 
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.LogOutButton.string, style: .Plain, target: self, action: "logOut:")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}


	// MARK: - Rows

	func rowForOrganization(organization: Organization) -> Row {
		var row = organization.row

		row.selection = { [weak self] in
			self?.openOrganization(organization)
		}

		return row
	}

	func openOrganization(organization: Organization) {
		guard !opening else { return }
		opening = true
		Analytics.track(.ChangedOrganization(organization: organization))
		let viewController = OrganizationCanvasesViewController(account: account, organization: organization)
		navigationController?.pushViewController(viewController, animated: true)
	}

	override func refresh() {
		if loading {
			return
		}

		loading = true

		APIClient(accessToken: account.accessToken, baseURL: baseURL).listOrganizations { [weak self] result in
			switch result {
			case .Success(let organizations):
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
					self?.updateOrganizations(organizations)
				}
			case .Failure(let message):
				print("Failed to get organizations: \(message)")
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
				}
			}
		}
	}


	// MARK: - Actions

	func logOut(sender: AnyObject?) {
		Analytics.track(.LoggedIn)
		AccountController.sharedController.currentAccount = nil
	}


	// MARK: - Private

	private func updateOrganizations(organizations: [Organization]) {
		dataSource.sections = [
			Section(rows: organizations.map({ rowForOrganization($0) }))
		]
	}
}
