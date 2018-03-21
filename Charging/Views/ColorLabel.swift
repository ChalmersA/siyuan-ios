//
//  ColorLabel.swift
//  Charging
//
//  Created by xpg on 7/21/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class ColorLabel: UILabel {

    // MARK: Properties
    let label: UILabel
    
    override var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
            super.text = nil
        }
    }
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        label = UILabel()
        super.init(coder: aDecoder)
        
        label.font = self.font
        label.textColor = self.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-4-[label]-4-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": label]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-4-[label]-4-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": label]))
        
        self.text = super.text
    }
    
    // MARK: Layout
    override func intrinsicContentSize() -> CGSize {
        let size = label.intrinsicContentSize()
        return CGSize(width: size.width + 8, height: size.height + 8)
    }
    
}
