//
//  OrganizationsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore
import CanvasKit

final class OrganizationsViewController: ModelsViewController, Accountable {

	// MARK: - Properties

	var account: Account


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		super.init(style: .Grouped)

		title = "Canvas" // TODO: Localize
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}



	// MARK: - UIResponder

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []
		commands += [
			UIKeyCommand(input: "1", modifierFlags: [.Command], action: #selector(openOrganization1), discoverabilityTitle: LocalizedString.PersonalNotes.string)
		]

		let organizationSelectors: [Selector] = [
			#selector(openOrganization2),
			#selector(openOrganization3),
			#selector(openOrganization4),
			#selector(openOrganization5),
			#selector(openOrganization6),
			#selector(openOrganization7),
			#selector(openOrganization8),
			#selector(openOrganization9)
		]

		if dataSource.sections.count > 1 {
			for (i, row) in dataSource.sections[1].rows.enumerate() {
				guard i < 8, let name = row.text else { continue }
				let command = UIKeyCommand(input: "\(i + 2)", modifierFlags: [.Command], action: organizationSelectors[i], discoverabilityTitle: name)
				commands.append(command)
			}
		}

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.estimatedRowHeight = 66
		 
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Gear"), style: .Plain, target: self, action: #selector(showSettings))
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
		showViewController(viewController, sender: self)

		NSUserDefaults.standardUserDefaults().setObject(organization.dictionary, forKey: "SelectedOrganization")
	}

	override func refresh() {
		refresh(nil)
	}

	func refresh(completion: (() -> Void)? = nil) {
		if loading {
			return
		}

		loading = true

		APIClient(account: account).listOrganizations { [weak self] result in
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

	func showSettings(sender: UIBarButtonItem?) {
		let viewController = SettingsViewController(account: account)
		let navigationController = NavigationController(rootViewController: viewController)
		navigationController.modalPresentationStyle = .FormSheet
		presentViewController(navigationController, animated: true, completion: nil)
	}

	func openAccount() {
		let URL = NSURL(string: "https://usecanvas.com/account")!
		UIApplication.sharedApplication().openURL(URL)
	}

	func showPersonalNotes(completion: (() -> Void)? = nil) {
		opening = false
		guard let selection = dataSource.sections.first?.rows.first?.selection else {
			refresh() { [weak self] in
				self?.showPersonalNotes(completion)
			}
			return
		}

		selection()
		completion?()
	}

	func openOrganization1() {
		dataSource.sections.first?.rows.first?.selection?()
	}

	func openOrganization2() {
		openOrganization(2)
	}

	func openOrganization3() {
		openOrganization(3)
	}

	func openOrganization4() {
		openOrganization(4)
	}

	func openOrganization5() {
		openOrganization(5)
	}

	func openOrganization6() {
		openOrganization(6)
	}

	func openOrganization7() {
		openOrganization(7)
	}

	func openOrganization8() {
		openOrganization(8)
	}

	func openOrganization9() {
		openOrganization(9)
	}


	// MARK: - Private

	private func updateOrganizations(organizations: [Organization]) {
		guard let personalIndex = organizations.indexOf({ $0.name == account.user.username }) else { return }

		var orgs = organizations
		let personal = orgs[personalIndex]
		orgs.removeAtIndex(personalIndex)

		var sections = [
			Section(rows: [rowForOrganization(personal)])
		]

		if orgs.count > 0 {
			let rows = orgs.map { rowForOrganization($0) }

			let header = GroupedSectionHeaderView()
			header.textLabel.text = LocalizedString.OrganizationsTitle.string.uppercaseString
			sections.append(Section(header: .View(header), rows: rows))
		}

		dataSource.sections = sections
	}


	private func openOrganization(number: Int) {
		guard dataSource.sections.count >= 2 else { return }
		let section = dataSource.sections[1]
		guard section.rows.count >= number - 1 else { return }
		section.rows[number - 2].selection?()
	}
}
