//
//  Shadow.swift
//  CanvasText
//
//  Created by Sam Soffes on 12/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Shadow {
	// NOTE: This isn't used anywhere yet
	public enum DeleteBehavior {
		/// Delete until the beginning of the line
		case BeginningOfLine

		/// Delete the shadow and the newline
		case Everything
	}

	public var backingRange: NSRange
	public var deleteBackwardBehavior: DeleteBehavior

	public init(backingRange: NSRange, deleteBackwardBehavior: DeleteBehavior = .Everything) {
		self.backingRange = backingRange
		self.deleteBackwardBehavior = deleteBackwardBehavior
	}
}
