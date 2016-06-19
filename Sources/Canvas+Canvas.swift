//
//  Canvas+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import Static

extension Canvas {
	enum Kind {
		case Document
		case Blank

		var icon: UIImage! {
			switch self {
			case .Document: return UIImage(named: "Document")
			case .Blank: return UIImage(named: "Document-Blank")
			}
		}
	}

	var row: Row {
		return Row(
			text: displayTitle,
			detailText: summary,
			cellClass: CanvasCell.self,
			context: ["canvas": self]
		)
	}

	var kind: Kind {
		return isEmpty ? .Blank : .Document
	}

	var displayTitle: String {
		return title.isEmpty ? LocalizedString.Untitled.string : title
	}
}
