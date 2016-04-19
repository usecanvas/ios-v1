//
//  Globals.swift
//  Canvas
//
//  Created by Sam Soffes on 12/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

enum LocalizedString {
	
	// Login
	case UsernamePlaceholder
	case PasswordPlaceholder
	case LoginButton

	// Organizations
	case OrganizationsTitle
	case LogOutButton

	// Canvases
	case SearchIn(organizationName: String)
	case SearchCommand
	case NewCanvasCommand
	case ArchiveSelectedCanvasCommand
	case DeleteSelectedCanvasCommand
	case ArchiveButton
	case DeleteButton
	case CancelButton
	case DeleteConfirmationMessage(canvasTitle: String)
	case ArchiveConfirmationMessage(canvasTitle: String)

	// Editor
	case CanvasTitlePlaceholder
	case CloseCommand
	case DismissKeyboardCommand
	case MarkAsCheckedCommand
	case MarkAsUncheckedCommand
	case IndentCommand
	case OutdentCommand

	case Loading


	// MARK: - Properties

	var string: String {
		switch self {
		case .UsernamePlaceholder: return localizedString("USERNAME_PLACEHOLDER")
		case .PasswordPlaceholder: return localizedString("PASSWORD_PLACEHOLDER")
		case .LoginButton: return localizedString("LOGIN_BUTTON")

		case .OrganizationsTitle: return localizedString("ORGANIZATIONS_TITLE")
		case .LogOutButton: return localizedString("LOG_OUT_BUTTON")

		case .SearchIn(let organizationName): return String(format: localizedString("SEARCH_IN_ORGANIZATION"), arguments: [organizationName])
		case .SearchCommand: return localizedString("SEARCH_COMMAND")
		case .NewCanvasCommand: return localizedString("NEW_CANVAS_COMMAND")
		case .ArchiveSelectedCanvasCommand: return localizedString("ARCHIVE_SELECTED_CANVAS_COMMAND")
		case .DeleteSelectedCanvasCommand: return localizedString("DELETE_SELECTED_CANVAS_COMMAND")
		case .ArchiveButton: return localizedString("ARCHIVE_BUTTON")
		case .DeleteButton: return localizedString("DELETE_BUTTON")
		case .CancelButton: return localizedString("CANCEL_BUTTON")
		case .DeleteConfirmationMessage(let canvasTitle): return String(format: localizedString("DELETE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])
		case .ArchiveConfirmationMessage(let canvasTitle): return String(format: localizedString("ARCHIVE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])

		case .CanvasTitlePlaceholder: return localizedString("CANVAS_TITLE_PLACEHOLDER")
		case .CloseCommand: return localizedString("CLOSE_COMMAND")
		case .DismissKeyboardCommand: return localizedString("DISMISS_KEYBOARD_COMMAND")
		case .MarkAsCheckedCommand: return localizedString("MARK_AS_CHECKED_COMMAND")
		case .MarkAsUncheckedCommand: return localizedString("MARK_AS_UNCHECKED_COMMAND")
		case .IndentCommand: return localizedString("INDENT_COMMAND")
		case .OutdentCommand: return localizedString("OUTDENT_COMMAND")

		case .Loading: return localizedString("LOADING")
		}
	}


	// MARK: - Private

	private func localizedString(key: String) -> String {
		return NSLocalizedString(key, comment: "")
	}
}
