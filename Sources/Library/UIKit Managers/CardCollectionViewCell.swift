import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }
}

