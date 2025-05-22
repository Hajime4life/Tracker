import Foundation

protocol CategoriesDelegate: AnyObject {
    func categoriesViewController(_ controller: CategoriesViewController, didSelectCategory title: String,
                                  isImageHidden: Bool)
}
