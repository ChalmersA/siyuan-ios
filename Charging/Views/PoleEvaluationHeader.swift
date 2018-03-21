//
//  PoleEvaluationHeader.swift
//  Charging
//
//  Created by chenzhibin on 15/10/10.
//  Copyright © 2015年 xpg. All rights reserved.
//

import UIKit

class PoleEvaluationHeader: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starsView: FiveStarsView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var environmentScoreLabel: UILabel!
    @IBOutlet weak var deviceScoreLabel: UILabel!
    @IBOutlet weak var speedScoreLabel: UILabel!
//    @IBOutlet weak var serviceScoreLabel: UILabel!
    
    static func ibInstance() -> PoleEvaluationHeader {
        let header = UINib(nibName: "PoleEvaluationHeader", bundle: nil).instantiateWithOwner(nil, options: nil).first as! PoleEvaluationHeader
        return header
    }

}
