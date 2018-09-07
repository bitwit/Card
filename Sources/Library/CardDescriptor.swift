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

public struct SectionHeaderDescriptor {
    public var viewType: UIView.Type
    
    var postConfig: ((Int, UIView) -> Void)?

    public let viewBuilder: () -> UIView
    public let viewConfigurer: (Int, UIView) -> Void
    public let sizeConfig: (Int) -> CGSize
    
    public init<V: Card> (
        cardType: V.Type,
        modelProvider: @escaping (Int) -> V.Model,
        postConfig: ((Int, V) -> Void)? = nil,
        sizeConfig: ((Int) -> CGSize)? = nil
        ) {
        
        viewBuilder = {
            let newCard: V = .loadedFromNib()
            return newCard
        }
        
        viewConfigurer = { index, view in
            guard let existingCard = view as? V else {
                fatalError("unexpected view type")
            }
            existingCard.model = modelProvider(index)
            postConfig?(index, existingCard)
        }
        
        self.sizeConfig = { index in
            return sizeConfig?(index) ?? V.defaultSize()
        }
        
        self.viewType = V.self
        self.postConfig = { int, view in
            guard let existingCard = view as? V else {
                fatalError("unexpected view type")
            }
            postConfig?(int, existingCard)
        }
    }
}
