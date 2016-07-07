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
	
	private var stickyContainerLeadingConstraint: NSLayoutConstraint!
	
	private let stickyContainer: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .Vertical
		return view
	}()
	
	private let pageControl: UIPageControl = {
		let control = UIPageControl()
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
		
		pageControl.addTarget(self, action: #selector(pageControlDidChange), forControlEvents: .ValueChanged)
		stickyContainer.addArrangedSubview(pageControl)
		
		let footer = UIButton()
		footer.translatesAutoresizingMaskIntoConstraints = false
		footer.backgroundColor = .redColor()
		footer.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
		stickyContainer.addArrangedSubview(footer)
		
		view.addSubview(stickyContainer)
		
		stickyContainerLeadingConstraint = stickyContainer.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor)
		
		NSLayoutConstraint.activateConstraints([
			stickyContainerLeadingConstraint,
			stickyContainer.widthAnchor.constraintEqualToAnchor(view.widthAnchor),
			stickyContainer.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
			
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
	
	@objc private func signUp() {
		let viewController = SessionsViewController()
		
		dataSource = nil
		hideStickyContainer()
		setViewControllers([viewController], direction: .Forward, animated: true, completion: nil)
	}
	
	private func hideStickyContainer() {
		UIView.animateWithDuration(0.3, animations: { [weak self] in
			guard let stickyContainer = self?.stickyContainer, view = self?.view else { return }
			self?.stickyContainerLeadingConstraint.active = false
			stickyContainer.trailingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
			stickyContainer.layoutIfNeeded()
		}, completion: { [weak self] _ in
			self?.stickyContainer.removeFromSuperview()
		})
	}
}


extension OnboardingViewController: UIPageViewControllerDataSource {
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		guard let index = pages.indexOf(viewController) where index > 0 else { return nil }
		return pages[index - 1]
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		guard let index = pages.indexOf(viewController) else { return nil }
		
		if index == pages.count - 1 {
			return SessionsViewController()
		}
		
		return pages[index + 1]
	}
}


extension OnboardingViewController: UIPageViewControllerDelegate {
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard let viewController = pageViewController.viewControllers?.first,
			index = pages.indexOf(viewController)
		else {
			hideStickyContainer()
			return
		}
		
		pageControl.currentPage = index
		view.bringSubviewToFront(pageControl)
	}
}
