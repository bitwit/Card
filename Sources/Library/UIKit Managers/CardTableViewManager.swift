import UIKit

public class CardTableViewManager<C: Card>: NSObject, UITableViewDataSource, UITableViewDelegate {

    public var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    public var cardDescriptor: CardDescriptor<C>!
    public var dataSourceManager: AnyDataSourceManager<C.Model>! {
        didSet {
            reloadData()
            dataSourceManager?.delegate = self
        }
    }
    
    public init(tableView: UITableView = UITableView.init(frame: .zero) ) {
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    public func setDataSourceManager<D: DataSourceManager> (_ dataSourceManager: D) where D.Content == C.Model {
        self.dataSourceManager = AnyDataSourceManager(dataSourceManager)
    }
    
    fileprivate func reloadData() {
        tableView.reloadData()
        print("reloading tableView >", dataSourceManager.sections.first!)
    }
    
    // MARK: - UICollectionViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard dataSourceManager != nil else {
            return 0
        }
        
        return dataSourceManager.sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceManager.sections[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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

extension CardTableViewManager: DataSourceManagerDelegate {
    
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
