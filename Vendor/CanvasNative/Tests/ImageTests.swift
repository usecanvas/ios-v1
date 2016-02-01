//
//  ImageTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class ImageTests: XCTestCase {
	func testImage() {
		let native = "⧙image-{\"ci\":\"22ab2e78-0efa-4f12-9c73-65dc10873357\",\"width\":1011,\"height\":679,\"url\":\"https://canvas-files-prod.s3.amazonaws.com/uploads/22ab2e78-0efa-4f12-9c73-65dc10873357/cover.jpg\"}⧘"
		let length = native.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
		let image = Image(string: native, enclosingRange: NSRange(location: 0, length: length))!

		XCTAssertEqual(NSRange(location: 0, length: length - 1), image.nativePrefixRange)
		XCTAssertEqual(NSRange(location: length - 1, length: 1), image.displayRange)
		XCTAssertEqual("22ab2e78-0efa-4f12-9c73-65dc10873357", image.ID)
		XCTAssertEqual(CGSize(width: 1011, height: 679), image.size)
		XCTAssertEqual(NSURL(string: "https://canvas-files-prod.s3.amazonaws.com/uploads/22ab2e78-0efa-4f12-9c73-65dc10873357/cover.jpg")!, image.URL)
	}
}
