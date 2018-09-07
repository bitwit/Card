import UIKit

public class CardTableViewManager<C: Card>: NSObject, UITableViewDataSource, UITableViewDelegate {

    public var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
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
    
    public var trailingActionsForRow: ((IndexPath, C) -> UISwipeActionsConfiguration?)?
    
    private var sizeSnapshot: [Int]?
    private var queuedItemChanges: [() -> Void] = []
    
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
    }
    
    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard dataSourceManager != nil else {
            return 0
        }
        
        let numSections = dataSourceManager.sections.count
        return numSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = dataSourceManager.sections[section].count
        return numRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        let item = dataSourceManager.sections[indexPath.section][indexPath.row]
        let cardView = cell.configure(withCardType: C.self, model: item)
        cardDescriptor.postConfig?(indexPath, cardView)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let onSelect = cardDescriptor.onSelect
            , let card = tableView.cellForRow(at: indexPath)?.cardView as? C else { return }
        onSelect(indexPath, card)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cardDescriptor.sizeConfig?(indexPath)?.height ?? C.defaultSize().height
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (sectionHeaderDescriptor?.sizeConfig(section) ?? .zero).height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = sectionHeaderDescriptor!.viewBuilder()
        sectionHeaderDescriptor?.viewConfigurer(section, view)
        return view
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
     }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let card = tableView.cellForRow(at: indexPath)?.cardView as? C else { return nil }
        return self.trailingActionsForRow?(indexPath, card)
    }
    
}

extension CardTableViewManager: DataSourceManagerDelegate {
    
  
    public func dataSourceManagerItemsWillChange() {
        queuedItemChanges.removeAll()
        sizeSnapshot = (0..<tableView.numberOfSections).map { tableView.numberOfRows(inSection: $0) }
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
        
        tableView?.performBatchUpdates({
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
            
            self?.tableView?.insertSections(IndexSet(integer: index), with: .automatic)
            self?.sizeSnapshot?.insert(0, at: index)
        }
    }
    
    fileprivate func deleteSection(at index: Int) {
        queuedItemChanges.append {
            [weak self] in
            
            self?.tableView?.deleteSections(IndexSet(integer: index), with: .automatic)
            self?.sizeSnapshot?.remove(at: index)
        }
    }
    
    fileprivate func insert(at indexPath: IndexPath) {
        queuedItemChanges.append {
            [weak self] in
            
            self?.tableView?.insertRows(at: [indexPath], with: .automatic)
            self?.sizeSnapshot?[indexPath.section] += 1
        }
    }
    
    fileprivate func delete(at indexPath: IndexPath) {
        queuedItemChanges.append {
            [weak self] in
            self?.tableView?.deleteRows(at: [indexPath], with: .automatic)
            self?.sizeSnapshot?[indexPath.section] -= 1
        }
    }
    
}
