//
//  ArticleCommentCell.swift
//  Charging
//
//  Created by chenzhibin on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class ArticleCommentCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.None
        avatar.setCornerRadius(avatar.bounds.midX)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: -
    func setupWithComment(comment: DCArticleComment) {
        avatar.isLoad = NSNumber.init(bool: true)
        avatar.hssy_sd_setImageWithURL(comment.avatarURL, placeholderImage: UIImage(named: "default_user_avatar_gray"))
        let attributedText = NSMutableAttributedString(string: comment.userName, attributes: [NSForegroundColorAttributeName: UIColor.paletteDCMainColor()])
        if let replyName = comment.replyUserName {
            attributedText.appendAttributedString(NSAttributedString(string: " 回复 ", attributes: [NSForegroundColorAttributeName: UIColor.paletteFontDarkGrayColor()]))
            attributedText.appendAttributedString(NSAttributedString(string: replyName, attributes: [NSForegroundColorAttributeName: UIColor.paletteDCMainColor()]))
        }
        nameLabel.attributedText = attributedText

        timeLabel.text = NSDateFormatter.circleArticleDateFormatter().stringFromDate(comment.time)
        contentLabel.text = comment.content
    }
}
