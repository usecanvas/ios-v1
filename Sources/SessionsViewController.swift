//
//  SessionsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class SessionsViewController: UIPageViewController {
	
	// MARK: - Properties
	
	private lazy var signUpViewController: UIViewController = {
		return SignUpViewController()
	}()
	
	private lazy var logInViewController: UIViewController = {
		return LogInViewController()
	}()
	
	
	// MARK: - Initializers
	
	convenience init() {
		self.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
		showSignUp(animated: false)
	}
	
	
	// MARK: - Actions
	
	func showLogIn(animated animated: Bool = true) {
		setViewControllers([logInViewController], direction: .Forward, animated: animated, completion: nil)
	}
	
	func showSignUp(animated animated: Bool = true) {
		setViewControllers([signUpViewController], direction: .Reverse, animated: animated, completion: nil)
	}	
}
