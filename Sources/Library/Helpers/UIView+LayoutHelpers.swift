import Foundation
import UIKit

extension UIView {
    
    @discardableResult
    public func constrainToSuperview(constant: CGFloat = 0) -> [NSLayoutConstraint] {
        return constrain(to: [.top, .leading, .trailing, .bottom], constant: constant)
    }
    
    @discardableResult
    public func constrain(to superviewEdges: [NSLayoutConstraint.Attribute], constant: CGFloat = 0) -> [NSLayoutConstraint]  {
        guard let superview = self.superview else { fatalError("view not inside of a superview") }
                
        translatesAutoresizingMaskIntoConstraints = false
       
        let constraints = superviewEdges.map { edge -> NSLayoutConstraint in
            let finalConstant = (edge == .trailing || edge == .bottom) ? -constant : constant
            return NSLayoutConstraint(item: self, attribute: edge, relatedBy: .equal, toItem: superview, attribute: edge, multiplier: 1, constant: finalConstant)
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
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
    
    @discardableResult
    public func constrain(width: CGFloat) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal
            , toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width)
        NSLayoutConstraint.activate([widthConstraint])
        return widthConstraint
    }
    
    @discardableResult
    public func constrain(height: CGFloat) -> NSLayoutConstraint {
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal
            , toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
        NSLayoutConstraint.activate([heightConstraint])
        return heightConstraint
    }
}
