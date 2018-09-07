import Foundation
import UIKit

public class CardPickerViewManager<C: Card>: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    public var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    public var cardDescriptor: CardDescriptor<C>!
    public var dataSourceManager: AnyDataSourceManager<C.Model>! {
        didSet {
            dataSourceManagerDidReset()
            dataSourceManager?.delegate = self
        }
    }
    
    public init(pickerView: UIPickerView = UIPickerView(frame: .zero) ) {
        super.init()
        self.pickerView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    public func setDataSourceManager<D: DataSourceManager> (_ dataSourceManager: D) where D.Content == C.Model {
        self.dataSourceManager = AnyDataSourceManager(dataSourceManager)
    }
    
    fileprivate func reloadData() {
        pickerView.reloadAllComponents()
    }
    
    // MARK: - UIPickerViewDataSource
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        guard dataSourceManager != nil else {
            return 0
        }
        return dataSourceManager.sections.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return dataSourceManager.sections[component].count
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let item = dataSourceManager.sections[component][row]
        
        let card: C
        if let existingCard = view as? C {
            card = existingCard
        } else {
            let cardView = C.create()
            card = cardView
        }
        card.model = item
        cardDescriptor.postConfig?(IndexPath(item: row, section: component), card)
        
        return card
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let onSelect = cardDescriptor.onSelect
            , let card = pickerView.view(forRow: row, forComponent: component) as? C else { return }
        
        onSelect(IndexPath(item: row, section: component), card)
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let indexPath = IndexPath(item: 0, section: component)
        let size = cardDescriptor.sizeConfig?(indexPath) ?? C.defaultSize()
        return size.width
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let indexPath = IndexPath(item: 0, section: component)
        let size = cardDescriptor.sizeConfig?(indexPath) ?? C.defaultSize()
        return size.height
    }
    
}

extension CardPickerViewManager: DataSourceManagerDelegate {
    
    public func dataSourceManagerItemsWillChange() {
        
    }
    
    public func dataSourceManagerSection(at sectionIndex: Int, did changeType: DataSourceManagerChangeType) {
        reloadData()
    }
    
    public func dataSourceManagerItem(at indexPath: IndexPath, did changeType: DataSourceManagerChangeType) {
        reloadData()
    }
    
    public func dataSourceManagerItemsDidChange() {
        print("picker items changed")
        reloadData()
    }
    
    public func dataSourceManagerDidReset() {
        reloadData()
    }
    
}
