import UIKit

final class OnboardingPageViewController: UIViewController {
    //MARK: Enum
    private enum Constants {
        static let horizontalInset: CGFloat = 20
        static let bottomOffSafeArea: CGFloat = 50
        static let horizontalPadding: CGFloat = 16
        static let bottomOffset: CGFloat = 270
    }
    // MARK: - Private variables
    private let page: OnboardingPage
    
    private lazy var imageBoarding: UIImageView = {
        let imageBoarding = UIImageView()
        imageBoarding.image = UIImage(named: page.imageName)
        imageBoarding.contentMode = .scaleAspectFit
        imageBoarding.translatesAutoresizingMaskIntoConstraints = false
        return imageBoarding
    }()
    
    private lazy var labelBoarding: UILabel = {
        let labelBoarding = UILabel()
        labelBoarding.font = .systemFont(ofSize: 32, weight: .bold)
        labelBoarding.text = page.titleText
        labelBoarding.numberOfLines = 2
        labelBoarding.textAlignment = .center
        labelBoarding.textColor = .ypBlack
        labelBoarding.translatesAutoresizingMaskIntoConstraints = false
        return labelBoarding
    }()
    
    private lazy var boardingButton = DefaultButton(title: ButtonTypes.onBoarding,
                                                 target: self,
                                                 action: #selector(didTapBoardingButton))
    
    // MARK: - Init
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder){
        assertionFailure("init(coder:) не поддерживается")
        return nil
    }
    // MARK: - Life Cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        configurationOnBoardingPageController()
        
    }
    //MARK: - Private Methods
    private func configurationOnBoardingPageController(){
        view.setSubviews([imageBoarding, labelBoarding, boardingButton])
        [imageBoarding, labelBoarding, boardingButton].hideMask()
        
        NSLayoutConstraint.activate([
            imageBoarding.topAnchor.constraint(equalTo: view.topAnchor),
            imageBoarding.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageBoarding.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageBoarding.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            labelBoarding.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -Constants.horizontalPadding),
            labelBoarding.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: Constants.horizontalPadding),
            labelBoarding.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -Constants.bottomOffset),
            
            boardingButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: Constants.horizontalInset),
            boardingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -Constants.horizontalInset),
            boardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: -Constants.bottomOffSafeArea)
        ])
        
        view.backgroundColor = .ypWhite
    }
    
    //MARK: - Private Action
    @objc private func didTapBoardingButton(){
        OnBoardingStorage.isOnboardingCompleted = true
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = TabBarController()
    }
}
