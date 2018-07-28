import UIKit
import Card

public class ExampleCard: UIView, Cardable {
    
    @IBOutlet weak var label: UILabel!
    
    public var model: String = "" {
        didSet {
            updateView()
        }
    }
    
    public static func create() -> Self {
        return loadedFromNib()
    }
    
    public static func defaultSize() -> CGSize {
        return .init(width: 100, height: 44)
    }
    
    public func updateView() {
        label.text = model
    }
}
