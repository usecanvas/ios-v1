//
//  SharedWebCredentials.swift
//  Canvas
//
//  Created by Sam Soffes on 6/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import Security

struct SharedWebCredentials {

	// MARK: - Types

	struct Credential {
		let domain: String
		let account: String
		let password: String

		init?(dictionary: NSDictionary) {
			let dict = dictionary as Dictionary

			guard let domain = dict[kSecAttrServer] as? String,
				account = dict[kSecAttrAccount] as? String,
				password = dict[kSecSharedPassword] as? String
			else { return nil }

			self.domain = domain
			self.account = account
			self.password = password
		}
	}


	// MARK: - Accessing Credentials

	static func get(domain domain: String? = nil, account: String? = nil, completion: (credential: Credential?, error: CFError?) -> Void) {
		if NSProcessInfo.processInfo().isSnapshotting {
			completion(credential: nil, error: nil)
			return
		}

		SecRequestSharedWebCredential(domain, account) { array, error in
			let credential: Credential?

			if let array = array as Array?, dictionary = array.first as? NSDictionary {
				credential = Credential(dictionary: dictionary)
			} else {
				credential = nil
			}

			completion(credential: credential, error: error)
		}
	}

	static func add(domain domain: String, account: String, password: String, completion: ((error: CFError?) -> Void)? = nil) {
		if NSProcessInfo.processInfo().isSnapshotting {
			completion?(error: nil)
			return
		}

		SecAddSharedWebCredential(domain, account, password) { error in
			completion?(error: error)
		}
	}

	static func remove(domain domain: String, account: String, completion: ((error: CFError?) -> Void)? = nil) {
		if NSProcessInfo.processInfo().isSnapshotting {
			completion?(error: nil)
			return
		}
		
		SecAddSharedWebCredential(domain, account, nil) { error in
			completion?(error: error)
		}
	}

	static func generatePassword() -> String? {
		return SecCreateSharedWebCredentialPassword() as String?
	}
}
