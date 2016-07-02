//
//  SettingsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import Static
import Intercom

final class SettingsViewController: TableViewController, Accountable {

	// MARK: - Properties

	var account: Account


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		super.init(style: .Grouped)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Settings"

		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: #selector(close))
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		tableView.rowHeight = 50

		dataSource.automaticallyDeselectRows = false
		reload()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reload), name: NSUserDefaultsDidChangeNotification, object: nil)
	}


	// MARK: - Private

	// TODO: Localize
	@objc private func reload() {
		let version = NSUserDefaults.standardUserDefaults().stringForKey("HumanReadableVersion")
		let footer = version.flatMap { Section.Extremity.Title("Version \($0)") }

		dataSource.sections = [
			Section(header: "Account", rows: [
				Row(text: "Username", detailText: account.user.username, image: UIImage(named: "Username")),
				Row(text: "Account Details…", accessory: .DisclosureIndicator, selection: showAccount, image: UIImage(named: "User"), cellClass: ValueCell.self)
			]),
			Section(header: "Editor", rows: [
				Row(text: "Prevent Sleep", detailText: SleepPrevention.currentPreference.description, accessory: .DisclosureIndicator, selection: showSleepPicker, image: UIImage(named: "Moon"), cellClass: ValueCell.self),
			]),
			Section(rows: [
				Row(text: "Help", cellClass: ButtonCell.self, selection: help, image: UIImage(named: "Help"))
			], footer: footer),
			Section(rows: [
				Row(text: "Log Out", cellClass: ButtonCell.self, selection: logOut, image: UIImage(named: "SignOut"))
			])
		]
	}


	// MARK: - Actions

	@objc private func close() {
		dismissViewControllerAnimated(true, completion: nil)
	}

	private func deselectRow() {
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
		}
	}

	private func showAccount() {
		deselectRow()
		guard let url = NSURL(string: "https://usecanvas.com/account") else { return }
		UIApplication.sharedApplication().openURL(url)
	}

	private func showSleepPicker() {
		let viewController = SleepPickerViewController()
		navigationController?.pushViewController(viewController, animated: true)
	}

	private func logOut() {
		deselectRow()
		AccountController.sharedController.currentAccount = nil
	}

	private func help() {
		deselectRow()

		let application = UIApplication.sharedApplication()
		let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
		application.registerUserNotificationSettings(settings)
		application.registerForRemoteNotifications()

		Intercom.presentMessageComposer()
	}
}
