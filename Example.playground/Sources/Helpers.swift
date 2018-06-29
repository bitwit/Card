import Foundation
import UIKit

/// A simple function for assisting with comprehension when making multiple changes to an object
///
/// - Parameters:
///   - object: the object to be changed/operated on
///   - changes: the closure of all changes/operations that will be applied
public func with<T: AnyObject>(_ object: T, changes: (T) -> Void) {
    changes(object)
}

public func with<T: Any>(_ structure: inout T, changes: (inout T) -> Void) {
    changes(&structure)
}

public func configure<T: AnyObject>(_ object: T, changes: (T) -> Void) -> T {
    changes(object)
    return object
}
