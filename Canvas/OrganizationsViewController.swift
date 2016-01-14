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

final class OrganizationsViewController: ModelsViewController, Accountable {

	// MARK: - Properties

	var account: Account

	private var animatePush = true


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
			UIKeyCommand(input: "Q", modifierFlags: [.Shift, .Command], action: "logOut", discoverabilityTitle: LocalizedString.LogOutButton.string)
		]
		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.estimatedRowHeight = 66
		 
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Settings"), style: .Plain, target: self, action: "showSettings:")
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
		navigationController?.pushViewController(viewController, animated: animatePush)
		animatePush = true
	}

	override func refresh() {
		refresh(nil)
	}

	func refresh(completion: (() -> Void)? = nil) {
		if loading {
			return
		}

		loading = true

		APIClient(accessToken: account.accessToken, baseURL: baseURL).listOrganizations { [weak self] result in
			dispatch_async(dispatch_get_main_queue()) {
				switch result {
				case .Success(let organizations):
					self?.loading = false
					self?.updateOrganizations(organizations)
				case .Failure(let message):
					print("Failed to get organizations: \(message)")
					self?.loading = false
				}

				completion?()
			}
		}
	}


	// MARK: - Actions

	func showSettings(sender: AnyObject?) {
		let style: UIAlertControllerStyle = traitCollection.userInterfaceIdiom == .Pad ? .Alert : .ActionSheet
		let actionSheet = AlertController(title:nil, message: nil, preferredStyle: style)

		actionSheet.addAction(UIAlertAction(title: LocalizedString.LogOutButton.string, style: .Destructive) { _ in self.logOut() })
		actionSheet.addAction(UIAlertAction(title: LocalizedString.CancelButton.string, style: .Cancel, handler: nil))
		actionSheet.primaryAction = logOut

		presentViewController(actionSheet, animated: true, completion: nil)
	}

	func logOut() {
		Analytics.track(.LoggedIn)
		AccountController.sharedController.currentAccount = nil
	}

	func showPersonalNotes(completion: (() -> Void)? = nil) {
		opening = false
		guard let selection = dataSource.sections.first?.rows.first?.selection else {
			refresh() { [weak self] in
				self?.showPersonalNotes(completion)
			}
			return
		}

		animatePush = false
		selection()
		completion?()
	}


	// MARK: - Private

	private func updateOrganizations(organizations: [Organization]) {
		guard let personalIndex = organizations.indexOf({ $0.name == account.user.username }) else { return }

		var orgs = organizations
		let personal = orgs[personalIndex]
		orgs.removeAtIndex(personalIndex)

		var personalRow = rowForOrganization(personal)
		personalRow.text = "Personal Notes"
		personalRow.cellClass = PersonalOrganizationCell.self

		dataSource.sections = [
			Section(rows: [personalRow]),
			Section(header: "Organizations", rows: orgs.map({ rowForOrganization($0) }))
		]
	}
}
