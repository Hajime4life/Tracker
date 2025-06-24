struct AlertModel {
    let title: String
    let message: String?
    
    let buttonText: String
    let completion: (() -> Void)?
    
    let secondButtonText: String?
    let secondButtonCompletion: (() -> Void)?
    
    var hasSecondButton: Bool {
        return secondButtonText != nil
    }
}
