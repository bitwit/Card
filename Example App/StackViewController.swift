import UIKit
import Card
import CardExamples

class StackViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arrayDataSourceManager = ArrayDataSourceManager(items: ["test", "tester", "testerino"])
        
        let mgr = CardStackViewManager<ExampleCard>(stackView: self.stackView)
        mgr.cardDescriptor = CardDescriptor()
        mgr.setDataSourceManager(arrayDataSourceManager)
    }
}

