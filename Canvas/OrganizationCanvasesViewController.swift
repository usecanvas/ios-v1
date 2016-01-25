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
import GradientView

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

		let searchBar = searchViewController.searchBar
		searchBar.barTintColor = .whiteColor()
		searchBar.layer.borderColor = UIColor.whiteColor().CGColor
		searchBar.layer.borderWidth = 1
		searchBar.backgroundColor = .whiteColor()

		super.init(account: account, style: .Plain)

		title = organization.name

		results.delegate = self

		searchViewController.searchBar.placeholder = LocalizedString.SearchIn(organizationName: organization.name).string
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
			UIKeyCommand(input: "/", modifierFlags: [], action: "search", discoverabilityTitle: LocalizedString.SearchCommand.string),
			UIKeyCommand(input: "n", modifierFlags: [.Command], action: "newCanvas", discoverabilityTitle: LocalizedString.NewCanvasCommand.string),
			UIKeyCommand(input: "e", modifierFlags: [.Command], action: "archiveSelectedCanvas", discoverabilityTitle: LocalizedString.ArchiveSelectedCanvasCommand.string),
			UIKeyCommand(input: "\u{8}", modifierFlags: [.Command], action: "deleteSelectedCanvas", discoverabilityTitle: LocalizedString.DeleteSelectedCanvasCommand.string)
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

		var frame = searchViewController.searchBar.bounds
		frame.size.height += 2
		let header = GradientView(frame: frame)
		header.backgroundColor = .whiteColor()
		header.topBorderColor = tableView.separatorColor
		header.bottomBorderColor = tableView.separatorColor
		searchViewController.searchBar.autoresizingMask = [.FlexibleWidth]

		frame = searchViewController.searchBar.bounds
		frame.origin.y += 1
		searchViewController.searchBar.frame = frame
		header.addSubview(searchViewController.searchBar)

		tableView.tableHeaderView = header

		let topView = UIView(frame: CGRect(x: 0, y: -400, width: view.bounds.width, height: 400))
		topView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
		topView.backgroundColor = UIColor(patternImage: UIImage(named: "Illustration")!)
		topView.alpha = 0.1
		tableView.addSubview(topView)

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Create Canvas"), style: .Plain, target: self, action: "createCanvas")
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

		APIClient(accessToken: account.accessToken, baseURL: baseURL).listCanvases(organization: organization) { [weak self] result in
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
			Row.EditAction(title: LocalizedString.DeleteButton.string, style: .Destructive, backgroundColor: Color.destructive, backgroundEffect: nil, selection: deleteCanvas(canvas)),
			Row.EditAction(title: LocalizedString.ArchiveButton.string, style: .Destructive, backgroundColor: Color.darkGray, backgroundEffect: nil, selection: archiveCanvas(canvas))
		]

		return row
	}


	// MARK: - Actions

	func createCanvas() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		// TODO: Avoid sending canvas-native here once the API is fixed
		APIClient(accessToken: account.accessToken, baseURL: baseURL).createCanvas(organization: organization) { [weak self] result in
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

	private func deleteCanvas(canvas: Canvas)() {
		let style: UIAlertControllerStyle = traitCollection.userInterfaceIdiom == .Pad ? .Alert : .ActionSheet
		let actionSheet = AlertController(title: LocalizedString.DeleteConfirmationMessage(canvasTitle: canvas.displayTitle).string, message: nil, preferredStyle: style)

		let delete = { [weak self] in
			guard let accessToken = self?.account.accessToken else { return }
			APIClient(accessToken: accessToken, baseURL: baseURL).destroyCanvas(canvas: canvas) { _ in
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

	private func archiveCanvas(canvas: Canvas)() {
		let style: UIAlertControllerStyle = traitCollection.userInterfaceIdiom == .Pad ? .Alert : .ActionSheet
		let actionSheet = AlertController(title: LocalizedString.ArchiveConfirmationMessage(canvasTitle: canvas.displayTitle).string, message: nil, preferredStyle: style)

		let archive = { [weak self] in
			guard let accessToken = self?.account.accessToken else { return }
			APIClient(accessToken: accessToken, baseURL: baseURL).archiveCanvas(canvas: canvas) { _ in
				dispatch_async(dispatch_get_main_queue()) {
					self?.refresh()
				}
			}
		}

		actionSheet.addAction(UIAlertAction(title: LocalizedString.ArchiveButton.string, style: .Destructive) { _ in archive() })
		actionSheet.addAction(UIAlertAction(title: LocalizedString.CancelButton.string, style: .Cancel, handler: nil))
		actionSheet.primaryAction = archive

		presentViewController(actionSheet, animated: true, completion: nil)
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
		return organization.color.UIColor
	}
}
