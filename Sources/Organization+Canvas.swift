//
//  Organization+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import Static

extension Organization {
	var isPersonalNotes: Bool {
		guard let account = AccountController.sharedController.currentAccount else { return false }
		return slug == account.user.username
	}

	var displayName: String {
		return isPersonalNotes ? LocalizedString.PersonalNotes.string : name
	}
	
	var row: Row {
		// TODO: Localize
		var detailText = "\(membersCount) member"
		if membersCount != 1 {
			detailText += "s"
		}

		return  Row(
			text: displayName,
			detailText: detailText,
			context: [
				"organization": self
			],
			cellClass: OrganizationCell.self
		)
	}
}
