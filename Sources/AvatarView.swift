//
//  AvatarView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit

final class AvatarView: UIImageView {

	// MARK: - Properties

	var user: User? {
		didSet {
			updateAvatar()
		}
	}


	// MARK: - Initializers

	init(user: User? = nil) {
		self.user = user

		super.init(frame: .zero)

		backgroundColor = Swatch.lightGray
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
		guard let user = user, url = user.avatarURL.flatMap(imgix) else {
			image = nil
			return
		}

		image = AvatarsController.sharedController.fetchImage(id: user.id, url: url) { [weak self] id, image in
			if id == self?.user?.id {
				self?.image = image
			}
		}
	}

	private func imgix(url: NSURL) -> NSURL? {
		let parameters = [
			NSURLQueryItem(name: "dpr", value: "\(Int(traitCollection.displayScale))"),
			NSURLQueryItem(name: "w", value: "\(32)"),
			NSURLQueryItem(name: "h", value: "\(32)"),
			NSURLQueryItem(name: "fit", value: "crop"),
			NSURLQueryItem(name: "crop", value: "faces")
		]

		return ImgixController.sign(url: url, parameters: parameters, configuration: config)
	}
}
