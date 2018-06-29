import UIKit
import Card
import CardExamples

class CollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arrayDataSourceManager = ArrayDataSourceManager(items: ["test", "tester", "testerino"])
        
        let mgr = CardCollectionViewManager<ExampleCard>(collectionView: self.collectionView!)
        mgr.cardDescriptor = CardDescriptor()
        mgr.setDataSourceManager(arrayDataSourceManager)
    }
}

