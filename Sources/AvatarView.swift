//
//  AvatarView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit

final class AvatarView: UIImageView {

	// MARK: - Properties

	var user: User {
		didSet {
			updateAvatar()
		}
	}


	// MARK: - Initializers

	init(user: User) {
		self.user = user

		super.init(frame: .zero)

		backgroundColor = Color.lightGray
		layer.cornerRadius = 16
		layer.masksToBounds = true

		updateAvatar()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func intrinsicContentSize() -> CGSize {
		return CGSize(width: 32, height: 32)
	}


	// MARK: - Private

	private func updateAvatar() {
		guard let url = user.avatarURL.flatMap(imgixURL) else {
			image = nil
			return
		}

		image = AvatarsController.sharedController.fetchImage(ID: user.ID, URL: url) { [weak self] ID, image in
			if ID == self?.user.ID {
				self?.image = image
			}
		}
	}

	private func imgixURL(URL: NSURL) -> NSURL? {
		let parameters = [
			NSURLQueryItem(name: "dpr", value: "\(Int(traitCollection.displayScale))"),
			NSURLQueryItem(name: "w", value: "\(32)"),
			NSURLQueryItem(name: "h", value: "\(32)"),
			NSURLQueryItem(name: "fit", value: "crop"),
			NSURLQueryItem(name: "crop", value: "faces")
		]

		return ImgixController.signURL(URL, parameters: parameters)
	}
}
