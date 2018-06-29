import Foundation
import UIKit

extension UIView {
    
    public func constrainToSuperview() {
        constrain(to: [.top, .trailing, .bottom, .leading])
    }
    
    public func constrain(to superviewEdges: [NSLayoutAttribute]) {
        guard let superview = self.superview else { fatalError("view not inside of a superview") }
                
        translatesAutoresizingMaskIntoConstraints = false
       
        let constraints = superviewEdges.map {
            NSLayoutConstraint(item: self, attribute: $0, relatedBy: .equal, toItem: superview, attribute: $0, multiplier: 1, constant: 0)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
}
