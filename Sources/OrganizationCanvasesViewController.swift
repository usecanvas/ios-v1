//
//  OrganizationCanvasesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore
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
			case .Today: return LocalizedString.TodayTitle.string
			case .Recent: return LocalizedString.RecentTitle.string
			case .Week: return LocalizedString.ThisWeekTitle.string
			case .Month: return LocalizedString.ThisMonthTitle.string
			case .Forever: return LocalizedString.OlderTitle.string
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

	var creating = false


	// MARK: - Initializers

	init(account: Account, organization: Organization) {
		self.organization = organization
		searchController = SearchController(client: APIClient(account: account), organizationID: organization.id)

		let results = CanvasesResultsViewController(account: account)
		searchViewController = UISearchController(searchResultsController: results)

		super.init(account: account, style: .Plain)

		title = organization.displayName

		searchViewController.searchBar.placeholder = LocalizedString.SearchIn(organizationName: organization.displayName).string
		searchViewController.searchResultsUpdater = searchController

		searchController.callback = { [weak self] canvases in
			guard let this = self, viewController = this.searchViewController.searchResultsController as? CanvasesViewController else { return }
			viewController.dataSource.sections = [
				Section(rows: canvases.map({ this.rowForCanvas($0) }))
			]
		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willCloseEditor), name: EditorViewController.willCloseNotificationName, object: nil)
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
		tableView.tableHeaderView = header

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Compose"), style: .Plain, target: self, action: #selector(createCanvas))
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		// Deselect search results *sigh*
		if let text = searchViewController.searchBar.text where !text.isEmpty {
			if let viewController = searchViewController.searchResultsController as? CanvasesViewController, indexPath = viewController.tableView.indexPathForSelectedRow {
				viewController.tableView.deselectRowAtIndexPath(indexPath, animated: animated)
			}
		}
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


	// MARK: - ModelsViewController

	override func refresh() {
		if loading {
			return
		}

		loading = true

		APIClient(account: account).listCanvases(organizationID: organization.id) { [weak self] result in
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
			Row.EditAction(title: LocalizedString.ArchiveButton.string, style: .Destructive, backgroundColor: Swatch.destructive, backgroundEffect: nil, selection: { [weak self] in
				self?.archiveCanvas(canvas)
			})
		]

		return row
	}


	// MARK: - Actions

	func createCanvas() {
		if creating {
			return
		}

		creating = true

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		APIClient(account: account).createCanvas(organizationID: organization.id) { [weak self] result in
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				self?.creating = false

				switch result {
				case .Success(let canvas):
					self?.openCanvas(canvas)
				case .Failure(_):
					self?.showBanner(text: "Failed to create canvas", style: .failure) // TODO: Localize
				}
			}
		}
	}

	func search() {
		searchViewController.searchBar.becomeFirstResponder()
	}

	private func archiveCanvas(canvas: Canvas) {
		clearEditor(canvas)
		removeCanvas(canvas)

		APIClient(account: account).archiveCanvas(id: canvas.id) { result in
			dispatch_async(dispatch_get_main_queue()) { [weak self] in
				self?.refresh()

				switch result {
				case .Success(_): return
				case .Failure(_): self?.showBanner(text: "Failed to archive canvas", style: .failure) // TODO: Localize
				}
			}
		}
	}


	// MARK: - Private

	// Clear the detail view controller if it contains the given canvas
	private func clearEditor(canvas: Canvas) {
		guard let viewController = currentEditor(), splitViewController = splitViewController
		where !splitViewController.collapsed
		else { return }

		if viewController.canvas == canvas {
			showDetailViewController(NavigationController(rootViewController: PlaceholderViewController()), sender: nil)
		}
	}

	private func removeCanvas(canvas: Canvas) {
		for (s, var section) in dataSource.sections.enumerate() {
			for (r, row) in section.rows.enumerate() {
				if let rowCanvas = row.context?["canvas"] as? Canvas where rowCanvas == canvas {
					section.rows.removeAtIndex(r)

					if section.rows.isEmpty {
						dataSource.sections.removeAtIndex(s)
					} else {
						dataSource.sections[s] = section
					}

					return
				}
			}
		}
	}

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

			let headerView = SectionHeaderView()
			headerView.textLabel.text = group.title

			sections.append(Section(header: .View(headerView), rows: rows))
		}

		dataSource.sections = sections
	}

	@objc private func willCloseEditor() {
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRowAtIndexPath(indexPath, animated: false)
		}
	}
}


extension OrganizationCanvasesViewController: TintableEnvironment {
	var preferredTintColor: UIColor {
		return organization.color?.uiColor ?? Swatch.brand
	}
}
