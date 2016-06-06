//
//  GroupedSectionHeaderView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class GroupedSectionHeaderView: SectionHeaderView {

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Color.groupedTableBackground
		
		textLabel.font = Font.sansSerif(size: .Small)
		textLabel.textColor = Color.gray
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
