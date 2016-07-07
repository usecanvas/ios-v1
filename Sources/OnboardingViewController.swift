//
//  OnboardingViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class OnboardingViewController: UIPageViewController {
	
	// MARK: - Properties
	
	private let welcomeViewController = OnboardingWelcomeViewController()
	
	private lazy var gesturesViewController: UIViewController = {
		return OnboardingGesturesViewController()
	}()
	
	private lazy var markdownViewController: UIViewController = {
		return OnboardingMarkdownViewController()
	}()
	
	private lazy var sharingViewController: UIViewController = {
		return OnboardingSharingViewController()
	}()
	
	private var pages: [UIViewController] {
		return [welcomeViewController, gesturesViewController, markdownViewController, sharingViewController]
	}
	
	private let pageControl: UIPageControl = {
		let control = UIPageControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.currentPageIndicatorTintColor = Swatch.gray
		control.pageIndicatorTintColor = Swatch.lightGray
		control.numberOfPages = 4
		return control
	}()
	
	// MARK: - Initializers
	
	convenience init() {
		self.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
		dataSource = self
		delegate = self
	}
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		
		setViewControllers([welcomeViewController], direction: .Forward, animated: false, completion: nil)
		
		let footer = UIView()
		footer.translatesAutoresizingMaskIntoConstraints = false
		footer.backgroundColor = .redColor()
		view.addSubview(footer)
		
		pageControl.addTarget(self, action: #selector(pageControlDidChange), forControlEvents: .ValueChanged)
		view.addSubview(pageControl)
		
		NSLayoutConstraint.activateConstraints([
			pageControl.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			pageControl.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			pageControl.bottomAnchor.constraintEqualToAnchor(footer.topAnchor),
			
			footer.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			footer.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			footer.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
			footer.heightAnchor.constraintEqualToConstant(48)
		])
	}
	
	
	// MARK: - Private
	
	@objc private func pageControlDidChange() {
		let oldIndex = viewControllers?.first.flatMap { pages.indexOf($0) } ?? 0
		let currentIndex = pageControl.currentPage
		
		if oldIndex == currentIndex {
			return
		}
		
		let direction: UIPageViewControllerNavigationDirection = currentIndex < oldIndex ? .Reverse : .Forward
		setViewControllers([pages[currentIndex]], direction: direction, animated: true, completion: nil)
	}
}


extension OnboardingViewController: UIPageViewControllerDataSource {
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		guard let index = pages.indexOf(viewController) where index > 0 else { return nil }
		return pages[index - 1]
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		guard let index = pages.indexOf(viewController) where index < pages.count - 1 else { return nil }
		return pages[index + 1]
	}
}


extension OnboardingViewController: UIPageViewControllerDelegate {
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard let viewController = pageViewController.viewControllers?.first,
			index = pages.indexOf(viewController)
		else { return }
		
		pageControl.currentPage = index
		view.bringSubviewToFront(pageControl)
	}
}
