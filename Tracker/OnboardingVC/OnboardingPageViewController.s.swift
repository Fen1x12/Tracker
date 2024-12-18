//
//  OnboardingPageViewController.s.swift
//  Tracker
//
//  Created by  Admin on 18.11.2024.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    private var pages = [OnboardingHelper]()
    
    private lazy var onboardingViewControllers: [OnboardingViewController] = {
        var vc = [OnboardingViewController]()
        pages.forEach { vc.append(OnboardingViewController(with: $0)) }
        return vc
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation)
        
        dataSource = self
        delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pages = makePages()
        setupPageControl()
        
        onboardingViewControllers = pages.map { OnboardingViewController(with: $0) }
        
        if let firstVC = onboardingViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func makePages() -> [OnboardingHelper] {
        let firstPage = OnboardingHelper(
            greeting: LocalizationKey.onboardingFirstPage.localized(),
            image: UIImage(named: "1") ?? UIImage()
        )
        let secondPage = OnboardingHelper(
            greeting: LocalizationKey.onboardingSecondPage.localized(),
            image: UIImage(named: "2") ?? UIImage()
        )
        return [firstPage, secondPage]
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingViewController,
              let index = onboardingViewControllers.firstIndex(of: onboardingVC) else {
            return nil
        }
        
        let previousIndex = (index == 0) ? onboardingViewControllers.count - 1 : index - 1
        return onboardingViewControllers[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingViewController,
              let index = onboardingViewControllers.firstIndex(of: onboardingVC) else {
            return nil
        }
        
        let nextIndex = (index == onboardingViewControllers.count - 1) ? 0 : index + 1
        return onboardingViewControllers[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let currentVC = viewControllers?.first,
           let index = onboardingViewControllers.firstIndex(of: currentVC as! OnboardingViewController) {
            pageControl.currentPage = index
        }
    }
}
