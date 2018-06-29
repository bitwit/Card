import Foundation

public class ArrayDataSourceManager<R: Resource>: DataSourceManager {

    public typealias Content = R
    
    public var sections: [[Content]] = []
    public var delegate: DataSourceManagerDelegate?
    
    public init(sections: [[Content]] = []) {
        self.sections = sections
    }

    public init(items: [Content] = []) {
        self.sections = [items]
    }

    open func prepend(_ item: Content) {
        
        //TODO: possibly create first section if not available
        guard var firstSection = self.sections.first else {
            print("no first section")
            return
        }
        
        self.delegate?.dataSourceManagerItemsWillChange()
        firstSection.append(item)
        self.sections[0] = firstSection
        let indexPath = IndexPath(item: 0, section: 0)
        self.delegate?.dataSourceManagerItem(at: indexPath, did: .add)
        self.delegate?.dataSourceManagerItemsDidChange()
    }
    
    open func append(_ item: Content) {
        self.append([item])
    }
    
    open func append(_ items: [Content]) {
        self.delegate?.dataSourceManagerItemsWillChange()
        
        //TODO: possibly create first section if not available
        guard var firstSection = self.sections.first else {
            print("no first section")
            return
        }
        items.forEach {
            item in
            firstSection.append(item)
            self.sections[0] = firstSection
            let indexPath = IndexPath(item: items.count - 1, section: 0)
            self.delegate?.dataSourceManagerItem(at: indexPath, did: .add)
        }
        self.delegate?.dataSourceManagerItemsDidChange()
    }
    
    open func remove(_ item: Content) {
        
        //TODO: possibly create first section if not available
        guard var firstSection = self.sections.first else {
            print("no first section")
            return
        }

        guard let index = firstSection.index(of: item) else {
            print("no index found")
            return
        }
        
        print("index", index)

        self.delegate?.dataSourceManagerItemsWillChange()
        firstSection.remove(at: index)
        self.sections[0] = firstSection
        let indexPath = IndexPath(item: index, section: 0)
        self.delegate?.dataSourceManagerItem(at: indexPath, did: .remove)
        self.delegate?.dataSourceManagerItemsDidChange()
    }
    
    open func reset() {
        sections = [[]]
    }
}
