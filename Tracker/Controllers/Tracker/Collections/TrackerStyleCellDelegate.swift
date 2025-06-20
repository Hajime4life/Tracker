import UIKit

protocol TrackerStyleCellDelegate: AnyObject {
    func trackerStyleCollectionServices(_ services: TrackerStyleCollectionServices,
                                        didSelectEmoji: DefaultController.Emojies,
                                        andColor color: UIColor)
}
