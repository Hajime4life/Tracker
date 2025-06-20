import Foundation

@objc(DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    func encode(with coder: NSCoder) {
    }
    
    override init() {
        super.init()
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<WeekViewModel> else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode(Set<WeekViewModel>.self, from: data as Data)
    }
    
    static func register() {
        let transformerName = NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        ValueTransformer.setValueTransformer(DaysValueTransformer(), forName: transformerName)
    }
}
