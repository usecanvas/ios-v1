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
	
	let viewControllers: [UIViewController]
	
	private var stickyLeadingConstraint: NSLayoutConstraint!
	
	private let stickyContainer: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .Vertical
		view.userInteractionEnabled = true
		return view
	}()
	
	private let pageControl: UIPageControl = {
		let control = UIPageControl()
		control.currentPageIndicatorTintColor = Swatch.gray
		control.pageIndicatorTintColor = Swatch.lightGray
		control.numberOfPages = 4
		return control
	}()
	
	private var currentViewController: UIViewController? {
		willSet {
			currentViewController?.viewWillDisappear(false)
			newValue?.viewWillAppear(false)
		}
		
		didSet {
			oldValue?.viewDidDisappear(false)
			currentViewController?.viewDidAppear(false)
		}
	}
	
	private let signUpViewController = SignUpViewController()
	private let logInViewController = LogInViewController()
	
	
	// MARK: - Initializers
	
	init() {
		viewControllers = [
			OnboardingWelcomeViewController(),
			OnboardingGesturesViewController(),
			OnboardingMarkdownViewController(),
			OnboardingSharingViewController(),
			signUpViewController,
			logInViewController
		]
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		
		viewControllers.forEach { viewController in
			addChildViewController(viewController)
			scrollView.addSubview(viewController.view)
		}
		
		scrollView.delegate = self
		view.addSubview(scrollView)
		
		logInViewController.footerButton.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
		signUpViewController.footerButton.addTarget(self, action: #selector(logIn), forControlEvents: .TouchUpInside)
		
		pageControl.addTarget(self, action: #selector(pageControlDidChange), forControlEvents: .ValueChanged)
		stickyContainer.addArrangedSubview(pageControl)
		
		let footer = Button()
		footer.translatesAutoresizingMaskIntoConstraints = false
		footer.setTitle("Get Started with Canvas", forState: .Normal) // TODO: Localize
		footer.layer.borderWidth = 0
		footer.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
		stickyContainer.addArrangedSubview(footer)
		
		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(line)
		
		view.addSubview(stickyContainer)
		
		stickyLeadingConstraint = stickyContainer.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor)
		
		NSLayoutConstraint.activateConstraints([
			scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
			
			stickyLeadingConstraint,
			stickyContainer.widthAnchor.constraintEqualToAnchor(view.widthAnchor),
			stickyContainer.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
			
			line.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			line.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
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
	
	private func scrollTo(page page: Int, animated: Bool = true) {
		let width = scrollView.frame.width
		let rect = CGRect(x: width * CGFloat(page), y: 0, width: width, height: 1)
		scrollView.scrollRectToVisible(rect, animated: animated)
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.3)), dispatch_get_main_queue()) { [weak self] in
			guard let scrollView = self?.scrollView else { return }
			self?.scrollViewDidScroll(scrollView)
			self?.scrollViewDidEndDecelerating(scrollView)
		}
	}
	
	@objc private func pageControlDidChange() {
		scrollTo(page: pageControl.currentPage)
	}
	
	@objc private func signUp() {
		scrollTo(page: pageControl.numberOfPages)
	}
	
	@objc private func logIn() {
		scrollTo(page: pageControl.numberOfPages + 1)
	}
}


extension OnboardingViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.x
		let width = scrollView.frame.width
		let numberOfPages = CGFloat(pageControl.numberOfPages)
		
		stickyLeadingConstraint.constant = -max(0, offset - (width * (numberOfPages - 1)))
	}
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.x
		let width = scrollView.frame.width
		let page = Int(floor((offset - width / 2) / width)) + 1
		
		pageControl.currentPage = min(pageControl.numberOfPages - 1, page)
		currentViewController = viewControllers[page]
		
		scrollView.scrollEnabled = page < pageControl.numberOfPages
	}
}
