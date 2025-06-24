import Foundation

struct GeometricParams {
    let cellCount: Int
    let cellSpacing: CGFloat
    let leftInset: CGFloat
    let rightInset: CGFloat
    let topInset:     CGFloat
    let bottomInset:  CGFloat
    
    init(
        cellCount: Int,
        cellSpacing: CGFloat,
        leftInset: CGFloat,
        rightInset: CGFloat,
        topInset: CGFloat,
        bottomInset: CGFloat
    ) {
        self.cellCount = cellCount
        self.cellSpacing = cellSpacing
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.topInset = topInset
        self.bottomInset = bottomInset
    }
}
