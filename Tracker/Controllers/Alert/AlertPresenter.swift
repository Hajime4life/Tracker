import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func present(_ model: AlertModel) {
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .actionSheet
        )
        
        let mainAction = UIAlertAction(
            title: model.buttonText,
            style: .destructive
        ) { _ in
            model.completion?()
        }
        alert.addAction(mainAction)
        
        if model.hasSecondButton, let text = model.secondButtonText {
            let cancelAction = UIAlertAction(
                title: text,
                style: .cancel
            ) { _ in
                model.secondButtonCompletion?()
            }
            alert.addAction(cancelAction)
        }
        
        viewController?.present(alert, animated: true)
    }
}
