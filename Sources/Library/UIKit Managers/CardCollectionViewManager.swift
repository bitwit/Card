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
    
    public var sectionHeaderDescriptor: SectionHeaderDescriptor?
    
    public var dataSourceManager: AnyDataSourceManager<C.Model>! {
        didSet {
            dataSourceManagerDidReset()
            dataSourceManager?.delegate = self
        }
    }
    
    // This is useful for some types of interactions such as when using drag/drop APIs to move items
    public var performMovesAsDeletionAndInsertion: Bool = false
    
    private var sizeSnapshot: [Int]?
    private var queuedItemChanges: [() -> Void] = []
    
    public init(collectionView: UICollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()) ) {
        super.init()
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCell")
    }
    
    public func setDataSourceManager<D: DataSourceManager> (_ dataSourceManager: D) where D.Content == C.Model {
        self.dataSourceManager = AnyDataSourceManager(dataSourceManager)
    }
    
    deinit {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.reloadData()
    }
    
    @discardableResult
    public func refreshHeader(at indexPath: IndexPath) -> UIView? {
        guard let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            , let existingCard = header.subviews.first else {
                return nil
        }
        sectionHeaderDescriptor?.viewConfigurer(indexPath.section, existingCard)
        return existingCard
    }
    
    @discardableResult
    public func visibleHeaders() -> [UIView] {
        return collectionView
            .visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
            .compactMap { $0.subviews.first }
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
        
        //TODO: fudgey
        guard dataSourceManager.sections.count > indexPath.section
            , dataSourceManager.sections[indexPath.section].count > indexPath.item else {
                return cell
        }
        
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
            , let card = collectionView.cellForItem(at: indexPath)?.cardView as? C else {
                print("no cardview as \(C.self), \(collectionView.cellForItem(at: indexPath)?.cardView)")
                return }
        onSelect(indexPath, card)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sectionHeaderDescriptor?.sizeConfig(section) ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCell", for: indexPath)

            if let existingCard = cell.subviews.first {
                sectionHeaderDescriptor?.viewConfigurer(indexPath.section, existingCard)
            } else {
                let view = sectionHeaderDescriptor!.viewBuilder()
                sectionHeaderDescriptor?.viewConfigurer(indexPath.section, view)
                cell.addSubview(view)
                view.constrainToSuperview()
            }
            return cell
        default:
            return UICollectionReusableView(frame: .zero)
        }
    }
    
}

extension CardCollectionViewManager: DataSourceManagerDelegate {
    
    public func dataSourceManagerItemsWillChange() {
        print("0- ITEMS WILL CHANGE")
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
        case .move(let object, let newIndexPath):
            move(from: indexPath, to: newIndexPath, object: object as! C.Model)
        case .update(let object):
            update(at: indexPath, object: object as! C.Model)
        }
    }
    
    public func dataSourceManagerDidReset() {
        //TODO: improve
        reloadData()
    }
    
    open func dataSourceManagerItemsDidChange() {
        let changes = queuedItemChanges
//        print("1- ITEMS DID CHANGE, TOTAL:", changes.count)
        guard false == changes.isEmpty else {
            sizeSnapshot = nil
            return
        }
        
        // If not currently visible, no need to animate changes
        guard collectionView.window != nil else {
            sizeSnapshot = nil
            collectionView.reloadData()
            return
        }
//        print("2- BATCH UPDATES START")
        collectionView?.performBatchUpdates({
            changes.forEach { $0() }
        }, completion: {
            [weak self] _ in
            self?.sizeSnapshot = nil
//            print("3- BATCH UPDATES DONE")
        })
        queuedItemChanges.removeAll()
    }
    
    fileprivate func insertSection(at index: Int) {
        queuedItemChanges.append {
            [weak self] in
            
//            print("insert section \(index)")
            self?.collectionView?.insertSections(IndexSet(integer: index))
            if index > (self?.sizeSnapshot?.count ?? 0) {
                self?.sizeSnapshot?.append(0)
            } else {
                self?.sizeSnapshot?.insert(0, at: index)
            }
        }
    }
    
    fileprivate func deleteSection(at index: Int) {
        queuedItemChanges.append {
            [weak self] in
//            print("delete section \(index)")
            self?.collectionView?.deleteSections(IndexSet(integer: index))
            if index == (self?.sizeSnapshot?.count ?? 0) {
                self?.sizeSnapshot?.removeLast()
            } else {
                self?.sizeSnapshot?.remove(at: index)
            }
        }
    }
    
    fileprivate func insert(at indexPath: IndexPath) {
        queuedItemChanges.append {
            [weak self] in
//            print("insert cell \(indexPath)")
            self?.collectionView?.insertItems(at: [indexPath])
            self?.sizeSnapshot?[indexPath.section] += 1
        }
    }
    
    fileprivate func move(from indexPath: IndexPath, to newIndexPath: IndexPath, object: C.Model) {
        queuedItemChanges.append {
            [weak self] in
            let card = self?.collectionView?.cellForItem(at: indexPath)?.cardView as? C
            card?.model = object
            
//            print("move cell \(indexPath) to \(newIndexPath)")
            
            if true == self?.performMovesAsDeletionAndInsertion {
                self?.collectionView?.deleteItems(at: [indexPath])
                self?.collectionView?.insertItems(at: [newIndexPath])
            } else {
                self?.collectionView?.moveItem(at: indexPath, to: newIndexPath)
            }
        }
    }
    
    fileprivate func update(at indexPath: IndexPath, object: C.Model) {
        queuedItemChanges.append {
            [weak self] in
            let card = self?.collectionView?.cellForItem(at: indexPath)?.cardView as? C
            card?.model = object //dataSourceManager.sections[indexPath.section][indexPath.item]
//            print("update cell \(indexPath) with", (object as! NSObject).value(forKey: "title"))
        }
    }
    
    fileprivate func delete(at indexPath: IndexPath) {
        queuedItemChanges.append {
            [weak self] in
//            print("delete cell \(indexPath)")
            self?.collectionView?.deleteItems(at: [indexPath])
            self?.sizeSnapshot?[indexPath.section] -= 1
        }
    }
}
