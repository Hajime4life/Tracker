import UIKit

final class OnboardingViewController: UIPageViewController {
    //MARK: Enum
    private enum Constants {
        static let bottomOffset: CGFloat = 134
    }
    
    private enum OnboardingStep: Int, CaseIterable {
        case onBoardingBlue
        case onBoardingRed
        
        private var imageName: String {
            switch self {
                case .onBoardingBlue:
                    return DefaultController.OnboardingImage.onBoardingBlue.imageName
                case .onBoardingRed:
                    return DefaultController.OnboardingImage.onBoardingRed.imageName
            }
        }
        
        private var titleText: String {
            switch self {
                case .onBoardingBlue:
                    return DefaultController.OnBoardingLabel.onBoardingBlue.text
                case .onBoardingRed:
                    return DefaultController.OnBoardingLabel.onBoardingRed.text
            }
        }
        
        var page: OnboardingPage {
            .init(imageName: imageName,
                  titleText: titleText,
                  index: rawValue,
                  total: OnboardingStep.allCases.count)
        }
    }
    
    //MARK: - Private variables
    private lazy var pages: [OnboardingPageViewController] = OnboardingStep.allCases.map { step in
        OnboardingPageViewController(page: step.page)
    }
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = .zero
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = UIColor.ypBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setupInitialPage()
        configurationOnBoardingViewController()
    }
    
    //MARK: - Private Methods
    private func setupInitialPage() {
        guard let first = pages.first else { return }
        setViewControllers([first], direction: .forward, animated: false)
    }
    
    private func configurationOnBoardingViewController(){
        view.addSubview(pageControl)
        [pageControl].hideMask()
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -Constants.bottomOffset)
        ])
        
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let newIndex = sender.currentPage
        guard
            let current = viewControllers?.first as? OnboardingPageViewController,
            let currentIndex = pages.firstIndex(of: current)
        else { return }
        
        let direction: UIPageViewController.NavigationDirection = newIndex > currentIndex ? .forward : .reverse
        
        sender.isEnabled = false
        
        setViewControllers([pages[newIndex]], direction: direction, animated: true) { [weak self] _ in
            guard let self = self else { return }
            self.pageControl.currentPage = newIndex
            sender.isEnabled = true
        }
    }
}
//MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let viewControllerIndex = viewController as? OnboardingPageViewController,
            let index = pages.firstIndex(of: viewControllerIndex),
            index > 0
        else {
            return nil
        }
        
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let viewControllerIndex = viewController as? OnboardingPageViewController,
            let index = pages.firstIndex(of: viewControllerIndex),
            index < pages.count - 1
        else {
            return nil
        }
        
        let nextIndex = index + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        return pages[nextIndex]
    }
}
//MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let current = viewControllers?.first as? OnboardingPageViewController,
              let index = pages.firstIndex(of: current)
        else { return }
        pageControl.currentPage = index
    }
}
