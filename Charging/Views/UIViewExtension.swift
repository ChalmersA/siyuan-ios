//
//  UIViewExtension.swift
//  Charging
//
//  Created by chenzhibin on 15/9/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviewsWithTableLayout(views: [UIView], spacing: CGFloat = 0) {
        for (index, view) in views.enumerate() {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            if index == 0 {
                addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: spacing))
            } else {
                let upperView = views[index - 1]
                addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: upperView, attribute: .Bottom, multiplier: 1, constant: spacing))
            }
            if index == views.count - 1 {
                addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -spacing))
            }
            
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-8-[view]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        }
    }
    
    func addConstraintWithHeight(height: CGFloat) {
        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height))
    }
    
    func addConstraintWithWidth(width: CGFloat) {
        addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: width))
    }
    
    func addConstraintsWithEdgeInsets(insets: UIEdgeInsets) {
        addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: insets.top))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: -insets.bottom))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1, constant: insets.left))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: superview, attribute: .Right, multiplier: 1, constant: -insets.right))
    }
}
