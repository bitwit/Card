import UIKit
import Card
import CardExamples

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arrayDataSourceManager = ArrayDataSourceManager(items: ["test", "tester", "testerino"])

        let mgr = CardTableViewManager<ExampleCard>(tableView: self.tableView)
        mgr.cardDescriptor = CardDescriptor()
        mgr.setDataSourceManager(arrayDataSourceManager)
    }
}

