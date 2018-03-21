//
//  FaqCell.swift
//  Charging
//
//  Created by xpg on 6/9/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class FaqCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
