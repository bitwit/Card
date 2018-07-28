import Foundation

public protocol CardContainerCell {
    var contentView: UIView { get }
}

extension CardContainerCell {
    
    public var cardView: UIView? {
        return contentView.subviews.first
    }
    
    public func configure<C: Card>(withCardType cardType: C.Type, model: C.Model) -> C {
        let cardView: C
        if let existingCard = self.cardView as? C {
            existingCard.model = model
            cardView = existingCard
        } else {
            let view = C.create()
            view.model = model
            contentView.addSubview(view)
            view.constrainToSuperview()
            cardView = view
        }
        return cardView
    }
}

extension UICollectionViewCell: CardContainerCell {}
extension UITableViewCell: CardContainerCell {}
