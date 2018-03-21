//
//  LikeCell.swift
//  Charging
//
//  Created by chenzhibin on 15/9/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class LikeCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .None
        avatarView.setCornerRadius(avatarView.bounds.midX)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWithLike(like: DCArticleLike) {
        avatarView.isLoad = true
        avatarView.hssy_sd_setImageWithURL(like.avatarURL, placeholderImage: UIImage(named: "default_user_avatar_gray"))
        nameLabel.text = like.userName
    }

}
