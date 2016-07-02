//
//  Analytics.swift
//  Canvas
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Mixpanel
import Intercom
import CanvasKit
import CanvasCore

struct Analytics {

	// MARK: - Types

	enum Event {
		case LoggedOut
		case LoggedIn
		case LaunchedApp
		case ChangedOrganization(organization: Organization)
		case OpenedCanvas

		var name: String {
			switch self {
			case .LoggedOut: return "Logged Out"
			case .LoggedIn: return "Logged In"
			case .LaunchedApp: return "Launched App"
			case .ChangedOrganization(_): return "Changed Organization"
			case .OpenedCanvas: return "Opened Canvas"
			}
		}

		var parameters: [String: AnyObject]? {
			switch self {
			case .ChangedOrganization(let organization): return ["organization_name": organization.name]
			default: return nil
			}
		}
	}


	// MARK: - Properties

	private static let mixpanel: Mixpanel = {
		var mp = Mixpanel(token: config.mixpanelToken)

		let uniqueIdentifier: String
		let key = "Identifier"
		if let identifier = NSUserDefaults.standardUserDefaults().stringForKey(key) {
			uniqueIdentifier = identifier
		} else {
			let identifier = NSUUID().UUIDString
			NSUserDefaults.standardUserDefaults().setObject(identifier, forKey: key)
			uniqueIdentifier = identifier
		}

		mp.identify(uniqueIdentifier)

		#if DEBUG
			mp.enabled = false
		#endif

		return mp
	}()


	// MARK: - Tracking

	static func track(event: Event) {
		// Params
		let params = event.parameters ?? [:]
		var mixpanelParams = params

		// Current user
		if let account = AccountController.sharedController.currentAccount {
			mixpanelParams["id"] = account.user.id
			mixpanelParams["$username"] = account.user.username
		}

		// Mixpanel
		mixpanel.track(event.name, parameters: mixpanelParams)

		// Intercom
		var intercomParams = params
		intercomParams["source"] = "ios"
		Intercom.logEventWithName(event.name, metaData: params)
	}
}
