import UIKit
import PlaygroundSupport
import Card
import CardExamples

let vc = MyViewController()
PlaygroundPage.current.liveView = vc

print("hi")

let arrayDataSourceManager = ArrayDataSourceManager(items: ["test", "tester", "testerino"])

//let stackViewMgr = configure(CardStackViewManager<ExampleCard>()) {
//    $0.cardDescriptor = CardDescriptor()
//    $0.setDataSourceManager(arrayDataSourceManager)
//    with($0.stackView) {
//        $0.axis = .vertical
//        vc.view.addSubview($0)
//        $0.constrain(to: [.top, .leading, .trailing])
//    }
//}

//let collectionViewMgr = configure(CardCollectionViewManager<ExampleCard>()) {
//    $0.cardDescriptor = CardDescriptor()
//    $0.setDataSourceManager(arrayDataSourceManager)
//    vc.view.addSubview($0.collectionView)
//    $0.collectionView.constrainToSuperview()
//}

let tableViewMgr
    = configure(CardTableViewManager<ExampleCard>()) {
    $0.cardDescriptor = CardDescriptor()
    $0.setDataSourceManager(arrayDataSourceManager)
    vc.view.addSubview($0.tableView)
    $0.tableView.constrainToSuperview()
}

_ = vc.view

arrayDataSourceManager.append("word")



