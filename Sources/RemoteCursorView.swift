//
//  RemoteCursorView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class RemoteCursorView: UIView {

	// MARK: - Properties

	var remoteCursor: RemoteCursor


	// MARK: - Initializers

	init(remoteCursor: RemoteCursor) {
		self.remoteCursor = remoteCursor
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
