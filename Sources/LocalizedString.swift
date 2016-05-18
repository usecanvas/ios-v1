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
	case LoginLabel
	case LoginPlaceholder
	case PasswordLabel
	case PasswordPlaceholder
	case LoginButton

	// Organizations
	case OrganizationsTitle
	case PersonalNotes
	case AccountButton
	case LogOutButton

	// Canvases
	case SearchIn(organizationName: String)
	case SearchCommand
	case InPersonalNotes
	case NewCanvasCommand
	case ArchiveSelectedCanvasCommand
	case DeleteSelectedCanvasCommand
	case ArchiveButton
	case DeleteButton
	case CancelButton
	case DeleteConfirmationMessage(canvasTitle: String)
	case ArchiveConfirmationMessage(canvasTitle: String)
	case UnsupportedTitle
	case UnsupportedMessage
	case CheckForUpdatesButton
	case OpenInSafariButton
	case TodayTitle
	case RecentTitle
	case ThisWeekTitle
	case ThisMonthTitle
	case OlderTitle

	// Editor
	case CanvasTitlePlaceholder
	case CloseCommand
	case DismissKeyboardCommand
	case MarkAsCheckedCommand
	case MarkAsUncheckedCommand
	case IndentCommand
	case OutdentCommand
	case BoldCommand
	case ItalicCommand
	case InlineCodeCommand
	case InsertLineAfterCommand
	case InsertLineBeforeCommand
	case DeleteLineCommand
	case SwapLineUpCommand
	case SwapLineDownCommand
	case Connecting
	case Disconnected

	case Okay
	case Cancel
	case Untitled


	// MARK: - Properties

	var string: String {
		switch self {
		case .LoginLabel: return string("LOGIN_LABEL")
		case .LoginPlaceholder: return string("LOGIN_PLACEHOLDER")
		case .PasswordLabel: return string("PASSWORD_LABEL")
		case .PasswordPlaceholder: return string("PASSWORD_PLACEHOLDER")
		case .LoginButton: return string("LOGIN_BUTTON")

		case .OrganizationsTitle: return string("ORGANIZATIONS_TITLE")
		case .PersonalNotes: return string("PERSONAL_NOTES")
		case .AccountButton: return string("ACCOUNT_BUTTON")
		case .LogOutButton: return string("LOG_OUT_BUTTON")

		case .SearchIn(let organizationName): return String(format: string("SEARCH_IN_ORGANIZATION"), arguments: [organizationName])
		case .SearchCommand: return string("SEARCH_COMMAND")
		case .InPersonalNotes: return string("IN_PERSONAL_NOTES")
		case .NewCanvasCommand: return string("NEW_CANVAS_COMMAND")
		case .ArchiveSelectedCanvasCommand: return string("ARCHIVE_SELECTED_CANVAS_COMMAND")
		case .DeleteSelectedCanvasCommand: return string("DELETE_SELECTED_CANVAS_COMMAND")
		case .ArchiveButton: return string("ARCHIVE_BUTTON")
		case .DeleteButton: return string("DELETE_BUTTON")
		case .CancelButton: return string("CANCEL_BUTTON")
		case .DeleteConfirmationMessage(let canvasTitle): return String(format: string("DELETE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])
		case .ArchiveConfirmationMessage(let canvasTitle): return String(format: string("ARCHIVE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])
		case .UnsupportedTitle: return string("UNSUPPORTED_TITLE")
		case .UnsupportedMessage: return string("UNSUPPORTED_MESSAGE")
		case .CheckForUpdatesButton: return string("CHECK_FOR_UPDATES_BUTTON")
		case .OpenInSafariButton: return string("OPEN_IN_SAFARI_BUTTON")
		case .TodayTitle: return string("TODAY_TITLE")
		case .RecentTitle: return string("RECENT_TITLE")
		case .ThisWeekTitle: return string("THIS_WEEK_TITLE")
		case .ThisMonthTitle: return string("THIS_MONTH_TITLE")
		case .OlderTitle: return string("OLDER_TITLE")

		case .CanvasTitlePlaceholder: return string("CANVAS_TITLE_PLACEHOLDER")
		case .CloseCommand: return string("CLOSE_COMMAND")
		case .DismissKeyboardCommand: return string("DISMISS_KEYBOARD_COMMAND")
		case .MarkAsCheckedCommand: return string("MARK_AS_CHECKED_COMMAND")
		case .MarkAsUncheckedCommand: return string("MARK_AS_UNCHECKED_COMMAND")
		case .IndentCommand: return string("INDENT_COMMAND")
		case .OutdentCommand: return string("OUTDENT_COMMAND")
		case .BoldCommand: return string("BOLD_COMMAND")
		case .ItalicCommand: return string("ITALIC_COMMAND")
		case .InlineCodeCommand: return string("INLINE_CODE_COMMAND")
		case .InsertLineAfterCommand: return string("INSERT_LINE_AFTER_COMMAND")
		case .InsertLineBeforeCommand: return string("INSERT_LINE_BEFORE_COMMAND")
		case .DeleteLineCommand: return string("DELETE_LINE_COMMAND")
		case .SwapLineUpCommand: return string("SWAP_LINE_UP_COMMAND")
		case .SwapLineDownCommand: return string("SWAP_LINE_DOWN_COMMAND")
		case .Connecting: return string("CONNECTING")
		case .Disconnected: return string("DISCONNECTED")

		case .Okay: return string("OK")
		case .Cancel: return string("CANCEL")
		case .Untitled: return string("UNTITLED")
		}
	}


	// MARK: - Private

	private func string(key: String) -> String {
		return NSLocalizedString(key, comment: "")
	}
}
