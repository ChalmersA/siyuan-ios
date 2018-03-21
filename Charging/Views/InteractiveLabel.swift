//
//  InteractiveLabel.swift
//  Charging
//
//  Created by chenzhibin on 15/9/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class InteractiveLabel: UILabel {

    var singleTapHandler: ((label: UILabel) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGesture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }
    
    func setupGesture() {
        userInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(InteractiveLabel.handleTap(_:)))
        addGestureRecognizer(singleTap)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if let handler = singleTapHandler {
                handler(label: self)
            }
        }
    }
}
