//
//  PresenceViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 8/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import Static

// TODO: Localize
final class PresenceViewController: TableViewController {

	// MARK: - Properties

	let canvasID: String
	let presenceController: PresenceController

	private var users = [User]() {
		didSet {
			billboardView.hidden = !users.isEmpty

			dataSource.sections = [
				Section(rows: users.map(row))
			]
		}
	}

	private let billboardView: BillboardView = {
		let view = BillboardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.illustrationView.image = UIImage(named: "No Participants")
		view.titleLabel.text = "No one’s here yet"
		view.titleLabel.textColor = Swatch.darkGray
		view.hidden = true
		return view
	}()


	// MARK: - Initializers

	init(canvasID: String, presenceController: PresenceController) {
		self.canvasID = canvasID
		self.presenceController = presenceController

		super.init(style: .Grouped)

		title = "Participants"
		presenceController.add(observer: self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		presenceController.remove(observer: self)
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: #selector(close))

		tableView.estimatedRowHeight = 50
		reloadUsers()

		view.addSubview(billboardView)

		NSLayoutConstraint.activateConstraints([
			billboardView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			billboardView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
		])
	}


	// MARK: - Actions

	@objc private func close() {
		dismissViewControllerAnimated(true, completion: nil)
	}


	// MARK: - Private

	private func row(user: User) -> Row {
		return Row(text: user.username ?? "Anonymous", cellClass: UserCell.self, context: ["user": user])
	}

	private func reloadUsers() {
		users = presenceController.users(canvasID: canvasID)
	}
}


extension PresenceViewController: PresenceObserver {
	func presenceController(controller: PresenceController, canvasID: String, userJoined user: User, cursor: Cursor?) {
		if canvasID == self.canvasID {
			reloadUsers()
		}
	}

	func presenceController(controller: PresenceController, canvasID: String, user: User, updatedCursor cursor: Cursor?) {
		// Do nothing
	}

	func presenceController(controller: PresenceController, canvasID: String, userLeft user: User) {
		if canvasID == self.canvasID {
			reloadUsers()
		}
	}
}
