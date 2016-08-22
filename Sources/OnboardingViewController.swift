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

	// MARK: - Types

	enum Screen {
		case logIn
		case signUp
	}

	
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
		control.currentPageIndicatorTintColor = Swatch.darkGray
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
	
	private let backSwipe: UIScreenEdgePanGestureRecognizer = {
		let recognizer = UIScreenEdgePanGestureRecognizer()
		recognizer.edges = .Left
		return recognizer
	}()
	private var startingOffset: CGFloat = 0


	// MARK: - Initializers
	
	init() {
		viewControllers = [
			OnboardingWelcomeViewController(),
			OnboardingGesturesViewController(),
			OnboardingOrigamiViewController(),
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
			scrollView.addSubview(viewController.view)
		}
		
		scrollView.delegate = self
		view.addSubview(scrollView)
		
		logInViewController.footerButton.addTarget(self, action: #selector(signUp), forControlEvents: .TouchUpInside)
		signUpViewController.footerButton.addTarget(self, action: #selector(logIn), forControlEvents: .TouchUpInside)
		
		pageControl.addTarget(self, action: #selector(pageControlDidChange), forControlEvents: .ValueChanged)
		stickyContainer.addArrangedSubview(pageControl)
		
		let footer = PrefaceButton()
		footer.translatesAutoresizingMaskIntoConstraints = false
		footer.setTitle("Get Started with Canvas", forState: .Normal) // TODO: Localize
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
		
		backSwipe.addTarget(self, action: #selector(didBackSwipe))
		view.addGestureRecognizer(backSwipe)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let size = view.bounds.size
		
		for (i, viewController) in viewControllers.enumerate() {
			viewController.view.frame = CGRect(x: CGFloat(i) * size.width, y: 0, width: size.width, height: size.height)
		}
		
		scrollView.contentSize = CGSize(width: size.width * CGFloat(viewControllers.count), height: size.height)
	}

	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

		let page = currentPageIndex()

		coordinator.animateAlongsideTransition({ [weak self] _ in
			self?.scrollTo(page: page, animated: false, width: size.width)
		}, completion: nil)
	}


	// MARK: - Choosing a Screen

	func scrollTo(screen screen: Screen, animated: Bool = true, completion: (Void -> ())? = nil) {
		let i: Int?

		switch screen {
		case .logIn: i = viewControllers.indexOf(logInViewController)
		case .signUp: i = viewControllers.indexOf(signUpViewController)
		}

		guard let index = i else { return }

		view.layoutIfNeeded()
		scrollTo(page: index, animated: animated, completion: completion)
	}

	
	// MARK: - Private
	
	private func scrollTo(page page: Int, animated: Bool = true, width: CGFloat? = nil, completion: (Void -> ())? = nil) {
		let width = width ?? scrollView.frame.width
		let rect = CGRect(x: width * CGFloat(page), y: 0, width: width, height: 1)

		UIView.animateWithDuration(animated ? 0.3 : 0, animations: { [weak self] in
			guard let scrollView = self?.scrollView else { return }
			scrollView.scrollRectToVisible(rect, animated: false)
			self?.stickyContainer.layoutIfNeeded()
		}, completion: { [weak self] _ in
			guard let scrollView = self?.scrollView else { return }
			self?.scrollViewDidScroll(scrollView)
			self?.scrollViewDidEndDecelerating(scrollView)
			completion?()
		})
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
	
	@objc private func didBackSwipe(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
		if scrollView.scrollEnabled {
			return
		}
		
		switch gestureRecognizer.state {
		case .Began: startingOffset = scrollView.contentOffset.x
		case .Changed: scrollView.contentOffset.x = startingOffset - gestureRecognizer.translationInView(view).x
		case .Ended: snapToPage()
		default: break
		}
	}
	
	private func currentPageIndex() -> Int {
		let offset = scrollView.contentOffset.x
		let width = scrollView.frame.width
		return Int(floor((offset - width / 2) / width)) + 1
	}
	
	private func snapToPage() {
		scrollTo(page: currentPageIndex())
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
		let page = currentPageIndex()
		
		pageControl.currentPage = min(pageControl.numberOfPages - 1, page)
		currentViewController = viewControllers[page]
		
		scrollView.scrollEnabled = page < pageControl.numberOfPages
	}
}
