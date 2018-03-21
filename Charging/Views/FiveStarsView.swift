//
//  FiveStarsView.swift
//  Charging
//
//  Created by xpg on 7/27/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class FiveStarsView: UIView {
    
    // MARK: Properties
    var starRateView: CWStarRateView!
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        starRateView = CWStarRateView(frame: bounds, numberOfStars: 5, referView: self)
        starRateView.userInteractionEnabled = false
        addSubview(starRateView)
        backgroundColor = UIColor.clearColor()
    }
    
    // MARK: -
    func setScore(score: Float) {
        starRateView.scorePercent = CGFloat( score / 5.0 );
    }

}
