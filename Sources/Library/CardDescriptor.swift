import Foundation

public struct CardDescriptor<C: Card> {
    
    public var postConfig: ((IndexPath, C) -> Void)?
    public var onSelect: ((IndexPath, C) -> Void)?
    public var sizeConfig: ((IndexPath) -> CGSize?)?
    public var expandedSizeConfig: ((IndexPath) -> CGFloat?)?
    
    // best way to do this? what about preferred content size?
    public func preferredSizeForView() -> CGSize {
        return C.defaultSize()
    }
    
    public init(
        postConfig: ((IndexPath, C) -> Void)? = nil
        , onSelect: ((IndexPath, C) -> Void)? = nil
        , sizeConfig: ((IndexPath) -> CGSize?)? = nil
        , expandedSizeConfig: ((IndexPath) -> CGFloat?)? = nil
        ) {
        
        self.postConfig = postConfig
        self.onSelect = onSelect
        self.sizeConfig = sizeConfig
        self.expandedSizeConfig = expandedSizeConfig
    }
    
}
