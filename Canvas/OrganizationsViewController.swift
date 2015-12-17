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
		super.init(nibName: nil, bundle: nil)
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

		view.backgroundColor = Color.lightGray
		tableView.rowHeight = 64
		tableView.separatorColor = Color.gray

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.LogOutButton.string, style: .Plain, target: self, action: "logOut:")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		guard let navigationBar = navigationController?.navigationBar else { return }

		navigationBar.barTintColor = Color.darkGray
		navigationBar.barStyle = .Black
		navigationBar.tintColor = Color.white.colorWithAlphaComponent(0.7)
//		navigationBar.translucent = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		guard let navigationBar = navigationController?.navigationBar else { return }

		navigationBar.barTintColor = Color.brand
//		navigationBar.translucent = false
	}


	// MARK: - ListViewController

	override var modelTypeName: String {
		return "Organization"
	}

	override func rowForModel(model: Model, isSelected: Bool) -> Row? {
		guard let organization = model as? Organization else { return nil }
		return Row(
			text: organization.name,
			accessory: .DisclosureIndicator,
			selection: { [weak self] in self?.selectModel(organization) },
			cellClass: isSelected ? SelectedOrganizationCell.self : OrganizationCell.self
		)
	}

	override func selectModel(model: Model) {
		guard !opening, let organization = model as? Organization else { return }
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
					self?.arrangedModels = organizations.map { $0 as Model }
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
}
