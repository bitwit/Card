import Foundation
import UIKit

public class CardStackViewManager<C: Card>: NSObject {
    
    public var stackView: UIStackView!
    public var cardDescriptor: CardDescriptor<C>!
    public var dataSourceManager: AnyDataSourceManager<C.Model>! {
        didSet {
            reloadData()
            dataSourceManager?.delegate = self
        }
    }
    
    public init(stackView: UIStackView = UIStackView(frame: .zero)) {
        self.stackView = stackView
    }
    
    public func setDataSourceManager<D: DataSourceManager> (_ dataSourceManager: D) where D.Content == C.Model {
        self.dataSourceManager = AnyDataSourceManager(dataSourceManager)
    }
    
    fileprivate func reloadData() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let cards = dataSourceManager.sections.first?.enumerated().map { idx, item -> C in
            let view = C.create()
            view.model = item
            view.constrain(size: cardDescriptor.sizeConfig?(IndexPath(item: idx, section: 0)) ?? C.defaultSize())
            view.tag = idx
            stackView.addArrangedSubview(view)
            return view
        }
        DispatchQueue.main.async {
            cards?.enumerated().forEach({ idx, card in
                if self.cardDescriptor.onSelect != nil {
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.cardTapped(sender:)))
                    card.addGestureRecognizer(tapRecognizer)
                    card.isUserInteractionEnabled = true
                }
                self.cardDescriptor.postConfig?(IndexPath(row: idx, section: 0), card)
            })
        }
        
    }
    
    public func forEach(action: (IndexPath, C) -> Void) {
        stackView.arrangedSubviews.enumerated().forEach({ idx, card in
            action(IndexPath(row: idx, section: 0), card as! C)
        })
    }
    
    public func cardForItem(at indexPath: IndexPath) -> C {
        return stackView.arrangedSubviews[indexPath.item] as! C
    }
    
    @objc func cardTapped(sender: UITapGestureRecognizer) {
        guard let idx = sender.view?.tag
            , let card = stackView.arrangedSubviews[idx] as? C
            else { return }
        
        cardDescriptor.onSelect?(IndexPath(row: idx, section: 0), card)
    }
}

extension CardStackViewManager: DataSourceManagerDelegate {
    
    public func dataSourceManagerItemsWillChange() {
        
    }
    
    public func dataSourceManagerSection(at sectionIndex: Int, did changeType: DataSourceManagerChangeType) {
        reloadData()
    }
    
    public func dataSourceManagerItem(at indexPath: IndexPath, did changeType: DataSourceManagerChangeType) {
        reloadData()
    }
    
    public func dataSourceManagerItemsDidChange() {
        print("items changed")
        reloadData()
    }
    
    public func dataSourceManagerDidReset() {
        reloadData()
    }
    
}
