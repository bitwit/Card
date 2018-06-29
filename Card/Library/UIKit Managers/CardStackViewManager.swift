import Foundation
import UIKit

public class CardStackViewManager<C: Card> {
    
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
        
        dataSourceManager.sections.first?.enumerated().forEach { idx, item in
            let view = cardDescriptor.cardType.create()
            view.model = item
            stackView.addArrangedSubview(view)
            cardDescriptor.postConfig(IndexPath(row: idx, section: 0), view)
        }
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
