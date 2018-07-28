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
    
    public func constrainToSuperviewSafeAreaEdges() {
        guard let superview = self.superview else { fatalError("view not inside of a superview") }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    public func constrain(size: CGSize) {
        constrain(width: size.width)
        constrain(height: size.height)
    }
    
    public func constrain(width: CGFloat) {
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal
            , toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width)
        NSLayoutConstraint.activate([widthConstraint])
    }
    
    public func constrain(height: CGFloat) {
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal
            , toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: height)
        NSLayoutConstraint.activate([heightConstraint])
    }
}
