import Foundation

public class AnyDataSourceManager<R: Resource>: DataSourceManager {
    
    public typealias Content = R
    
    public var sections: [[R]] {
        get { return _getSections() }
    }
    
    public var delegate: DataSourceManagerDelegate? {
        get { return _getDelegate() }
        set { _setDelegate(newValue) }
    }
    
    fileprivate var _getSections: () -> [[R]]
    
    fileprivate var _getDelegate: () -> DataSourceManagerDelegate?
    fileprivate var _setDelegate: (DataSourceManagerDelegate?) -> Void
    
    init<D: DataSourceManager>(_ dataSourceManager: D) where D.Content == R {
        _getSections = {
            return dataSourceManager.sections
        }
        _getDelegate = {
            return dataSourceManager.delegate
        }
        _setDelegate = {
            dataSourceManager.delegate = $0
        }
    }
    
}
