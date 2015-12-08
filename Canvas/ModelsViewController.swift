//
//  ModelsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import Static

class ModelsViewController: TableViewController {

	// MARK: - Properties

	var arrangedModels = [Model]() {
		didSet {
			reloadRows()
		}
	}

	var selectedModel: Model? {
		didSet {
			reloadRows()
		}
	}

	var loading = false {
		didSet {
			if !loading {
				refreshControl?.endRefreshing()
			}
		}
	}

	var opening = false


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []
		commands += [
			UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: "selectPrevious", discoverabilityTitle: "Previous  \(modelTypeName)"),
			UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: "selectNext", discoverabilityTitle: "Next  \(modelTypeName)"),
			UIKeyCommand(input: "\r", modifierFlags: [], action: "openSelected", discoverabilityTitle: "Open \(modelTypeName)"),
			UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: "openSelected"),
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "clearSelected", discoverabilityTitle: "Clear Selection")
		]

		if canRefresh {
			commands.append(UIKeyCommand(input: "R", modifierFlags: [.Command], action: "refresh", discoverabilityTitle: "Refresh"))
		}

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let control = UIRefreshControl()
		control.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
		refreshControl = control
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		opening = false
	}


	// MARK: - Configuration

	var modelTypeName: String {
		fatalError("Subclasses must override this method.")
	}

	var canRefresh = true

	func rowForModel(model: Model, isSelected: Bool) -> Row? {
		fatalError("Subclasses must override this method.")
	}

	func selectModel(model: Model) {
		fatalError("Subclasses must override this method.")
	}


	// MARK: - Actions

	func refresh() {
		fatalError("Subclasses must override this method.")
	}


	// MARK: - Private

	private func rowForModel(model: Model) -> Row? {
		let selected = selectedModel.flatMap { $0.ID == model.ID } ?? false
		return rowForModel(model, isSelected: selected)

	}

	@objc private func selectPrevious() {
		guard let selectedModel = selectedModel, index = arrangedModels.indexOf({ $0.ID == selectedModel.ID }) else {
			self.selectedModel = arrangedModels.first
			return
		}

		if index == 0 {
			return
		}

		self.selectedModel = arrangedModels[index.predecessor()]
	}

	@objc private func selectNext() {
		guard let selectedModel = selectedModel, index = arrangedModels.indexOf({ $0.ID == selectedModel.ID }) else {
			self.selectedModel = arrangedModels.first
			return
		}

		if index == arrangedModels.count - 1 {
			return
		}

		self.selectedModel = arrangedModels[index.successor()]

	}

	@objc private func openSelected() {
		guard let model = selectedModel ?? arrangedModels.first else { return }
		selectModel(model)
	}

	@objc private func clearSelected() {
		selectedModel = nil
	}


	// MARK: - Private

	private func reloadRows() {
		dataSource.sections = [
			Section(rows: arrangedModels.flatMap { rowForModel($0) })
		]
	}
}
