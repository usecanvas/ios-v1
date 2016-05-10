//
//  OrganizationCanvasesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit

final class OrganizationCanvasesViewController: CanvasesViewController {

	// MARK: - Types

	private enum Group: String {
		case Today
		case Recent // 3 days
		case Week
		case Month
		case Forever

		var title: String {
			switch self {
			case .Week: return "This Week"
			case . Month: return "This Month"
			case .Forever: return "Older"
			default: return rawValue
			}
		}

		func containsDate(date: NSDate) -> Bool {
			let calendar = NSCalendar.currentCalendar()

			let now = NSDate()

			switch self {
			case .Today:
				return calendar.isDateInToday(date)
			case .Recent:
				guard let end = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: -3, toDate: now, options: []) else { return false }
				return calendar.compareDate(date, toDate: end, toUnitGranularity: .Day) == .OrderedDescending
			case .Week:
				guard let end = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: -7, toDate: now, options: []) else { return false }
				return calendar.compareDate(date, toDate: end, toUnitGranularity: .Day) == .OrderedDescending
			case .Month:
				guard let end = calendar.dateByAddingUnit(NSCalendarUnit.Month, value: -1, toDate: now, options: []) else { return false }
				return calendar.compareDate(date, toDate: end, toUnitGranularity: .Day) == .OrderedDescending
			case .Forever:
				return true
			}
		}

		static let all: [Group] = [.Today, .Recent, .Week, .Month, .Forever]
	}


	// MARK: - Properties

	let organization: Organization

	private let searchController: SearchController

	private let searchViewController: UISearchController

	var ready: (() -> Void)?


	// MARK: - Initializers

	init(account: Account, organization: Organization) {
		self.organization = organization
		searchController = SearchController(account: account, organization: organization)

		let results = CanvasesResultsViewController(account: account)
		searchViewController = UISearchController(searchResultsController: results)

		super.init(account: account, style: .Plain)

		title = organization.displayName

		results.delegate = self

		searchViewController.searchBar.placeholder = LocalizedString.SearchIn(organizationName: organization.displayName).string
		searchViewController.searchResultsUpdater = searchController

		searchController.callback = { [weak self] canvases in
			guard let this = self, viewController = this.searchViewController.searchResultsController as? CanvasesViewController else { return }
			viewController.dataSource.sections = [
				Section(rows: canvases.map({ this.rowForCanvas($0) }))
			]
		}
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []

		commands += [
			UIKeyCommand(input: "/", modifierFlags: [], action: #selector(search), discoverabilityTitle: LocalizedString.SearchCommand.string),
			UIKeyCommand(input: "n", modifierFlags: [.Command], action: #selector(createCanvas), discoverabilityTitle: LocalizedString.NewCanvasCommand.string)
		]

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// Search setup
		definesPresentationContext = true
		extendedLayoutIncludesOpaqueBars = true
		searchViewController.hidesNavigationBarDuringPresentation = true

		// http://stackoverflow.com/a/33734661/118631
		searchViewController.loadViewIfNeeded()

		let header = SearchBarContainer(searchBar: searchViewController.searchBar)
		header.autoresizingMask = [.FlexibleWidth]
		tableView.tableHeaderView = header

		let topView = UIView(frame: CGRect(x: 0, y: -400, width: view.bounds.width, height: 400))
		topView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
		topView.backgroundColor = UIColor(patternImage: UIImage(named: "Illustration")!)
		topView.alpha = 0.03
		tableView.addSubview(topView)

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Create Canvas"), style: .Plain, target: self, action: #selector(createCanvas))
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			if let ready = self?.ready {
				ready()
				self?.ready = nil
			}
		}
	}

//	override func viewDidLayoutSubviews() {
//		super.viewDidLayoutSubviews()
//
//		guard let header = tableView.tableHeaderView else { return }
//		var frame = header.frame
//		frame.size.width = tableView.bounds.width
//		header.frame = frame
//	}


	// MARK: - ModelsViewController

	override func refresh() {
		if loading {
			return
		}

		loading = true

		APIClient(accessToken: account.accessToken, baseURL: config.baseURL).listCanvases(organization: organization) { [weak self] result in
			switch result {
			case .Success(let canvases):
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
					self?.updateCanvases(canvases)
				}
			case .Failure(let message):
				print("Failed to get canvases: \(message)")
				dispatch_async(dispatch_get_main_queue()) {
					self?.loading = false
				}
			}
		}
	}


	// MARK: - CanvasesViewController

	override  func rowForCanvas(canvas: Canvas) -> Row {
		var row = super.rowForCanvas(canvas)

		row.editActions = [
			Row.EditAction(title: LocalizedString.DeleteButton.string, style: .Destructive, backgroundColor: Color.destructive, backgroundEffect: nil, selection: { [weak self] in
				self?.deleteCanvas(canvas)
			}),
			Row.EditAction(title: LocalizedString.ArchiveButton.string, style: .Destructive, backgroundColor: Color.darkGray, backgroundEffect: nil, selection: { [weak self] in
				self?.archiveCanvas(canvas)
			})
		]

		return row
	}


	// MARK: - Actions

	func createCanvas() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		APIClient(accessToken: account.accessToken, baseURL: config.baseURL).createCanvas(organization: organization) { [weak self] result in
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false

				switch result {
				case .Success(let canvas):
					self?.openCanvas(canvas)
				case .Failure(let message):
					print("Failed to create canvas: \(message)")
				}
			}
		}
	}

	func search() {
		searchViewController.searchBar.becomeFirstResponder()
	}

	private func deleteCanvas(canvas: Canvas) {
		let style: UIAlertControllerStyle = traitCollection.userInterfaceIdiom == .Pad ? .Alert : .ActionSheet
		let actionSheet = AlertController(title: LocalizedString.DeleteConfirmationMessage(canvasTitle: canvas.displayTitle).string, message: nil, preferredStyle: style)

		let delete = { [weak self] in
			guard let accessToken = self?.account.accessToken else { return }
			APIClient(accessToken: accessToken, baseURL: config.baseURL).destroyCanvas(canvas: canvas) { _ in
				dispatch_async(dispatch_get_main_queue()) {
					self?.refresh()
				}
			}
		}

		actionSheet.addAction(UIAlertAction(title: LocalizedString.DeleteButton.string, style: .Destructive) { _ in delete() })
		actionSheet.addAction(UIAlertAction(title: LocalizedString.CancelButton.string, style: .Cancel, handler: nil))
		actionSheet.primaryAction = delete

		presentViewController(actionSheet, animated: true, completion: nil)
	}

	private func archiveCanvas(canvas: Canvas) {
		APIClient(accessToken: account.accessToken, baseURL: config.baseURL).archiveCanvas(canvas: canvas) { _ in
			dispatch_async(dispatch_get_main_queue()) { [weak self] in
				self?.refresh()
			}
		}
	}


	// MARK: - Private

	private func updateCanvases(canvases: [Canvas]) {
		var groups = [Group: [Canvas]]()

		for canvas in canvases {
			for group in Group.all {
				if group.containsDate(canvas.updatedAt) {
					var list = groups[group] ?? [Canvas]()
					list.append(canvas)
					groups[group] = list
					break
				}
			}
		}

		var sections = [Section]()
		for group in Group.all {
			guard let canvases = groups[group] else { continue }

			let rows = canvases.map { rowForCanvas($0) }
			sections.append(Section(header: .Title(group.title), rows: rows))
		}

		dataSource.sections = sections
	}
}


extension OrganizationCanvasesViewController: CanvasesResultsViewControllerDelegate {
	func canvasesResultsViewController(viewController: CanvasesResultsViewController, didSelectCanvas canvas: Canvas) {
		openCanvas(canvas)
	}
}


extension OrganizationCanvasesViewController: TintableEnvironment {
	var preferredTintColor: UIColor {
		return organization.color?.color ?? Color.brand
	}
}
