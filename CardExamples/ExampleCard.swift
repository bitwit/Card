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
    
    public static func loadedFromNib<T: AnyObject>() -> T {
        let bundle = Bundle.init(for: T.self)
        let view = bundle.loadNibNamed(String(describing: T.self), owner: self, options: nil)![0]
        guard let castView = view as? T else {
            fatalError("derp")
        }
        return castView
    }
    
    public static func defaultSize() -> CGSize {
        return .init(width: 100, height: 44)
    }
    
    public func updateView() {
        label.text = model
        backgroundColor = .white
    }
}
