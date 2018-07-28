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
            dataSourceManagerDidReset()
            dataSourceManager?.delegate = self
        }
    }
    
    private var sizeSnapshot: [Int]?
    private var queuedItemChanges: [() -> Void] = []
    
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let item = dataSourceManager.sections[indexPath.section][indexPath.item]
        let cardView = cell.configure(withCardType: C.self, model: item)
        cardDescriptor.postConfig?(indexPath, cardView)
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cardDescriptor.sizeConfig?(indexPath) ?? C.defaultSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let onSelect = cardDescriptor.onSelect
            , let card = collectionView.cellForItem(at: indexPath)?.cardView as? C else { return }
        onSelect(indexPath, card)
    }
    
}

extension CardCollectionViewManager: DataSourceManagerDelegate {
    
    public func dataSourceManagerItemsWillChange() {
        queuedItemChanges.removeAll()
        sizeSnapshot = (0..<collectionView.numberOfSections).map { collectionView.numberOfItems(inSection: $0) }
    }
    
    public func dataSourceManagerSection(at sectionIndex: Int, did changeType: DataSourceManagerChangeType) {
        
        switch changeType {
        case .add:
            insertSection(at: sectionIndex)
        case .remove:
            deleteSection(at: sectionIndex)
        default:
            break
        }
    }
    
    public func dataSourceManagerItem(at indexPath: IndexPath, did changeType: DataSourceManagerChangeType) {
        
        switch changeType {
        case .add:
            insert(at: indexPath)
        case .remove:
            delete(at: indexPath)
        default:
            break
        }
    }
    
    public func dataSourceManagerDidReset() {
        
        //TODO: improve
        reloadData()
    }
    
    open func dataSourceManagerItemsDidChange() {
        let changes = queuedItemChanges
        
        guard false == changes.isEmpty else {
            sizeSnapshot = nil
            return
        }
        
        collectionView?.performBatchUpdates({
            changes.forEach { $0() }
        }, completion: {
            [weak self] _ in
            self?.sizeSnapshot = nil
        })
        queuedItemChanges.removeAll()
    }
    
    fileprivate func insertSection(at index: Int) {
        queuedItemChanges.append {
            [weak self] in
            
            self?.collectionView?.insertSections(IndexSet(integer: index))
            self?.sizeSnapshot?.insert(0, at: index)
        }
    }
    
    fileprivate func deleteSection(at index: Int) {
        queuedItemChanges.append {
            [weak self] in
            
            self?.collectionView?.deleteSections(IndexSet(integer: index))
            self?.sizeSnapshot?.remove(at: index)
        }
    }
    
    fileprivate func insert(at indexPath: IndexPath) {
        queuedItemChanges.append {
            [weak self] in
            
            self?.collectionView?.insertItems(at: [indexPath])
            self?.sizeSnapshot?[indexPath.section] += 1
        }
    }
    
    fileprivate func delete(at indexPath: IndexPath) {
        queuedItemChanges.append {
            [weak self] in
            self?.collectionView?.deleteItems(at: [indexPath])
            self?.sizeSnapshot?[indexPath.section] -= 1
        }
    }
}
