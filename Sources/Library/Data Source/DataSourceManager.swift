import Foundation

public protocol DataSourceManager: class {
    
    associatedtype Content where Content: Resource
    
    var sections: [[Content]] { get }
    var delegate: DataSourceManagerDelegate? { get set }
}

public enum DataSourceManagerChangeType {
    case add
    case remove
    case update(Any)
    case move(Any, IndexPath)
}

public protocol DataSourceManagerDelegate: class {
    
    func dataSourceManagerItemsWillChange()
    func dataSourceManagerSection(at sectionIndex: Int, did changeType: DataSourceManagerChangeType)
    func dataSourceManagerItem(at indexPath: IndexPath, did changeType: DataSourceManagerChangeType)
    func dataSourceManagerItemsDidChange()
    func dataSourceManagerDidReset()
}

extension DataSourceManager {
    
    public var isEmpty: Bool {
        return sections.count == 0 || (sections.count == 1 && sections[0].isEmpty)
    }
}
