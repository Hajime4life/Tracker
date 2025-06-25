import UIKit

enum PlaceholderType {
    case emptyTrackers
    case noSearchResults
    
    var image: UIImage? {
        switch self {
            case .emptyTrackers: return UIImage(named: DefaultController.ImageNames.dizzy.imageName)
            case .noSearchResults: return UIImage(named: DefaultController.ImageNames.filter.imageName)
        }
    }
    
    var text: String {
        switch self {
            case .emptyTrackers: return DefaultController.Labels.dizzyLabel.text
            case .noSearchResults: return DefaultController.Labels.nothingFound.text
        }
    }
}
