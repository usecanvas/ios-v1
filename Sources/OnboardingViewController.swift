//
//  OnboardingViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class OnboardingViewController: UIViewController {
	
	// MARK: - Properties
	
	let scrollView: UIScrollView = {
		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.showsVerticalScrollIndicator = false
		view.showsHorizontalScrollIndicator = false
		view.pagingEnabled = true
		return view
	}()
	
	let viewControllers = [
		OnboardingWelcomeViewController(),
		OnboardingGesturesViewController(),
		OnboardingMarkdownViewController(),
		OnboardingSharingViewController(),
		LogInViewController(),
		SignUpViewController()
	]
	
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
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		
		viewControllers.forEach { viewController in
			addChildViewController(viewController)
			scrollView.addSubview(viewController.view)
		}
		view.addSubview(scrollView)
		
		pageControl.addTarget(self, action: #selector(pageControlDidChange), forControlEvents: .ValueChanged)
		stickyContainer.addArrangedSubview(pageControl)
		
		let footer = Button()
		footer.translatesAutoresizingMaskIntoConstraints = false
		footer.setTitle("Get Started with Canvas", forState: .Normal)
		footer.layer.borderWidth = 0
		footer.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
		stickyContainer.addArrangedSubview(footer)
		
		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		footer.addSubview(line)
		
		scrollView.addSubview(stickyContainer)
		
		let logInView = viewControllers[4].view
		
//		let stickyLeading1 = stickyContainer.leadingAnchor.constraintLessThanOrEqualToAnchor(view.leadingAnchor)
//		stickyLeading1.priority = UILayoutPriorityDefaultLow
//		
//		let stickyLeading2 = stickyContainer.trailingAnchor.constraintLessThanOrEqualToAnchor(logInView.leadingAnchor)
//		stickyLeading2.priority = UILayoutPriorityDefaultHigh
		
		NSLayoutConstraint.activateConstraints([
			scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
			
			stickyContainer.leadingAnchor.constraintLessThanOrEqualToAnchor(scrollView.leadingAnchor),
			stickyContainer.trailingAnchor.constraintGreaterThanOrEqualToAnchor(scrollView.leadingAnchor),
			stickyContainer.trailingAnchor.constraintLessThanOrEqualToAnchor(logInView.leadingAnchor),
			stickyContainer.widthAnchor.constraintEqualToAnchor(view.widthAnchor),
			stickyContainer.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
			
			line.leadingAnchor.constraintEqualToAnchor(footer.leadingAnchor, constant: -300),
			line.trailingAnchor.constraintEqualToAnchor(footer.trailingAnchor),
			line.topAnchor.constraintEqualToAnchor(footer.topAnchor),
			
			footer.heightAnchor.constraintEqualToConstant(48)
		])
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let size = view.bounds.size
		
		for (i, viewController) in viewControllers.enumerate() {
			viewController.view.frame = CGRect(x: CGFloat(i) * size.width, y: 0, width: size.width, height: size.height)
		}
		
		scrollView.contentSize = CGSize(width: size.width * CGFloat(viewControllers.count), height: size.height)
	}
	
	
	// MARK: - Private
	
	@objc private func pageControlDidChange() {
//		let oldIndex = viewControllers?.first.flatMap { pages.indexOf($0) } ?? 0
//		let currentIndex = pageControl.currentPage
//		
//		if oldIndex == currentIndex {
//			return
//		}
//		
//		let direction: UIPageViewControllerNavigationDirection = currentIndex < oldIndex ? .Reverse : .Forward
//		setViewControllers([pages[currentIndex]], direction: direction, animated: true, completion: nil)
	}
	
	@objc private func signUp() {
//		let viewController = SessionsViewController()
		
//		setViewControllers([viewController], direction: .Forward, animated: true, completion: nil)
	}
}
