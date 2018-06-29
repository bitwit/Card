import Foundation
import UIKit

public typealias Card = UIView & Cardable

public protocol Cardable: class {
    
    associatedtype Model: Resource
    
    var model: Model { get set }
    
    static func create () -> Self
    static func defaultSize () -> CGSize
}

public struct CardDescriptor<C: Card> {
    
    public var cardType: C.Type {
        return C.self
    }
    public let postConfig: (IndexPath, C) -> Void
    public let onSelect: (IndexPath, C) -> Void
    public let sizeConfig: (IndexPath) -> CGSize?
    public let expandedSizeConfig: (IndexPath) -> CGFloat?
    
    // best way to do this? what about preferred content size?
    public func preferredSizeForView() -> CGSize {
        return self.cardType.defaultSize()
    }
    
    public init(
        postConfig: ((IndexPath, C) -> Void)? = nil
        , onSelect: ((IndexPath, C) -> Void)? = nil
        , sizeConfig: ((IndexPath) -> CGSize?)? = nil
        , expandedSizeConfig: ((IndexPath) -> CGFloat?)? = nil
        ) {
        
        self.postConfig = {
            indexPath, card in
            postConfig?(indexPath, card)
        }
        
        self.sizeConfig = {
            indexPath in
            return sizeConfig?(indexPath)
        }
        
        self.expandedSizeConfig = {
            indexPath in
            return expandedSizeConfig?(indexPath)
        }
        
        self.onSelect = {
            indexPath, card in
            onSelect?(indexPath, card)
        }
    }
    
}
