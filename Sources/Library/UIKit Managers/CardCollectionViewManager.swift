import Foundation
import UIKit

public class CardCollectionViewManager<C: Card>: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    public var cardDescriptor: CardDescriptor<C>!
    public var dataSourceManager: AnyDataSourceManager<C.Model>! {
        didSet {
            reloadData()
            dataSourceManager?.delegate = self
        }
    }
    
    public init(collectionView: UICollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()) ) {
        super.init()
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    public func setDataSourceManager<D: DataSourceManager> (_ dataSourceManager: D) where D.Content == C.Model {
        self.dataSourceManager = AnyDataSourceManager(dataSourceManager)
    }
    
    fileprivate func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard dataSourceManager != nil else {
            return 0
        }
        
        return dataSourceManager.sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceManager.sections[section].count
    }
    
    //TODO: improve card reuse logic
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let view = cardDescriptor.cardType.create()
        let item = dataSourceManager.sections[indexPath.section][indexPath.item]
        view.model = item
        cardDescriptor.postConfig(indexPath, view)
        cell.addSubview(view)
        view.constrainToSuperview()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cardDescriptor.preferredSizeForView()
    }
    
}

extension CardCollectionViewManager: DataSourceManagerDelegate {
    
    public func dataSourceManagerItemsWillChange() {
        
    }
    
    public func dataSourceManagerSection(at sectionIndex: Int, did changeType: DataSourceManagerChangeType) {
        reloadData()
    }
    
    public func dataSourceManagerItem(at indexPath: IndexPath, did changeType: DataSourceManagerChangeType) {
        reloadData()
    }
    
    public func dataSourceManagerItemsDidChange() {
        reloadData()
    }
    
    public func dataSourceManagerDidReset() {
        reloadData()
    }
    
}
