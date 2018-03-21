//
//  ArticleLikeBarCell.swift
//  Charging
//
//  Created by chenzhibin on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class ArticleLikeBarCell: UITableViewCell {

    @IBOutlet weak var likeBar: ImagesBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - 
    func setupWithArticle(article: DCArticle) {
        likeBar.setImageURLs(article.likeAvatarURLs as! [NSURL], placeholderImage: UIImage(named: "default_user_avatar_gray"))
    }

}
