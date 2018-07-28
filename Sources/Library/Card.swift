import Foundation
import UIKit

public typealias Card = UIView & Cardable

public protocol Cardable: class {
    
    associatedtype Model: Resource
    
    var model: Model? { get set }
    
    static func create () -> Self
    static func defaultSize () -> CGSize
}

extension Cardable {
    
    public static func loadedFromNib<T: AnyObject>() -> T {
        let bundle = Bundle.init(for: T.self)
        let view = bundle.loadNibNamed(String(describing: T.self), owner: self, options: nil)![0]
        guard let castView = view as? T else {
            fatalError("Nib exists by the correct name but first view was not a \(String(describing: T.self))")
        }
        return castView
    }
}
