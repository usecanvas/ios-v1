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

	let canvas: Canvas
	let presenceController: PresenceController

	private var users = [User]()

	private let noContentView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .Vertical
		view.hidden = true

		let billboard = BillboardView()
		billboard.illustrationView.image = UIImage(named: "No Participants")
		billboard.titleLabel.text = "No one’s here yet"
		billboard.titleLabel.textColor = Swatch.darkGray
		view.addArrangedSubview(billboard)

		return view
	}()

	private let copyLinkView = CopyLinkView()


	// MARK: - Initializers

	init(canvas: Canvas, presenceController: PresenceController) {
		self.canvas = canvas
		self.presenceController = presenceController

		super.init(style: .Grouped)

		title = "Participants"
		presenceController.add(observer: self)

		copyLinkView.button.addTarget(self, action: #selector(copyLink), forControlEvents: .TouchUpInside)
		noContentView.addArrangedSubview(copyLinkView)
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

		let copy = CopyLinkView()
		let size = copy.systemLayoutSizeFittingSize(tableView.bounds.size)
		copy.frame = CGRect(origin: .zero, size: size)
		copy.button.addTarget(self, action: #selector(copyLink), forControlEvents: .TouchUpInside)
		copy.hidden = true
		tableView.tableFooterView = copy

		view.addSubview(noContentView)

		NSLayoutConstraint.activateConstraints([
			noContentView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			noContentView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
		])

		reloadUsers()
	}


	// MARK: - Actions

	@objc private func close() {
		dismissViewControllerAnimated(true, completion: nil)
	}

	@objc private func copyLink() {
		UIPasteboard.generalPasteboard().URL = canvas.url
		showBanner(text: "Copied Link!", style: .success)
	}


	// MARK: - Private

	private func row(user: User) -> Row {
		return Row(text: user.username ?? "Anonymous", cellClass: UserCell.self, context: ["user": user])
	}

	private func reloadUsers() {
		users = presenceController.users(canvasID: canvas.id)

		noContentView.hidden = !users.isEmpty
		tableView.tableFooterView?.hidden = users.isEmpty

		dataSource.sections = [
			Section(rows: users.map(row))
		]
	}
}


extension PresenceViewController: PresenceObserver {
	func presenceController(controller: PresenceController, canvasID: String, userJoined user: User, cursor: Cursor?) {
		if canvasID == canvas.id {
			reloadUsers()
		}
	}

	func presenceController(controller: PresenceController, canvasID: String, user: User, updatedCursor cursor: Cursor?) {
		// Do nothing
	}

	func presenceController(controller: PresenceController, canvasID: String, userLeft user: User) {
		if canvasID == canvas.id {
			reloadUsers()
		}
	}
}
