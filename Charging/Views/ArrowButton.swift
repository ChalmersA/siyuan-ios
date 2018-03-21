//
//  ArrowButton.swift
//  Charging
//
//  Created by xpg on 8/25/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

//@IBDesignable
class ArrowButton: UIControl {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBInspectable var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    @IBInspectable var textColor: UIColor! {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }
    
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            super.selected = newValue
            UIView.animateWithDuration(0.3) {
                self.arrowImage.layer.transform = newValue ? CATransform3DMakeRotation(CGFloat(M_PI), 1, 0, 0) : CATransform3DIdentity
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let view = NSBundle(forClass: ArrowButton.self).loadNibNamed("ArrowButton", owner: self, options: nil)!.first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.userInteractionEnabled = false
        view.backgroundColor = UIColor.clearColor()
        addSubview(view)
    }

}
