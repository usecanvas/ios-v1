//
//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {
	
	// MARK: - Properties
	
	let textView: EditorView = {
		let view = EditorView() //collectionID: "10ef574f-7a70-4b21-8fb1-fec3c49f941b", canvasID: "1323fedf-4fda-4463-93d8-56f574f5d06a")
		view.translatesAutoresizingMaskIntoConstraints = false
		view.editable = false
		return view
	}()
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .whiteColor()
		view.addSubview(textView)
		
		NSLayoutConstraint.activateConstraints([
			textView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			textView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			textView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
			textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
	}
}
