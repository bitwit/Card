import UIKit
import Card
import CardExamples

class CollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cvfl = collectionViewLayout as? UICollectionViewFlowLayout {
            cvfl.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        }
        
        let arrayDataSourceManager = ArrayDataSourceManager(items: [
            "test",
            "tester",
            String(repeating: "test ", count: 30)
            ])
        
        let mgr = CardCollectionViewManager<ExampleCard>(collectionView: self.collectionView!)
        mgr.cardDescriptor = CardDescriptor()
        mgr.setDataSourceManager(arrayDataSourceManager)
    }
}

