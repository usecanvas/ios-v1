//
//  AvatarView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import CryptoSwift

class AvatarView: UIView {

	// MARK: - Properties

	var user: User? {
		didSet {
			guard let user = user else {
				imageView.image = nil
				return
			}

			// TODO: Load avatar
			imageView.image = self.dynamicType.placeholderAvatar(email: user.email)
		}
	}

	private let imageView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private static let cache = NSCache()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Color.gray
		layer.cornerRadius = 16
		layer.masksToBounds = true

		addSubview(imageView)

		NSLayoutConstraint.activateConstraints([
			imageView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			imageView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			imageView.topAnchor.constraintEqualToAnchor(topAnchor),
			imageView.bottomAnchor.constraintEqualToAnchor(bottomAnchor),

			widthAnchor.constraintEqualToAnchor(heightAnchor)
		])
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func sizeThatFits(size: CGSize) -> CGSize {
		return intrinsicContentSize()
	}

	override func intrinsicContentSize() -> CGSize {
		return CGSize(width: 32, height: 32)
	}


	// MARK: - Private

	private static func avatarURL(email email: String) -> NSURL? {
		let hash = email.lowercaseString.md5()
		return NSURL(string: "https://www.gravatar.com/avatar/\(hash).jpg?s=64&d=404")
	}

	private static func placeholderAvatar(email email: String) -> UIImage? {
		let crc = email.lowercaseString.utf8.map { $0 as UInt8 }.crc32()
		let hash = UInt64.withBytes(crc) % 20
		return UIImage(named: "Avatar-\(hash)")
	}
}
