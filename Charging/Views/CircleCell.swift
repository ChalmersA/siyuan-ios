//
//  CircleCell.swift
//  Charging
//
//  Created by chenzhibin on 15/9/11.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class CircleCell: UITableViewCell {

    // MARK: -
    weak var delegate: CircleCellDelegate?
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var imagesView: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreStarsView: FiveStarsView!
    @IBOutlet weak var titleStarsView: FiveStarsView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentButtonLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var commentView: UIView!
    weak var likeBar: ImagesBar?
    var commentLabels: [UILabel] = []
    weak var moreButton: UIButton?
    var imagesBottomConstraint: NSLayoutConstraint!
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.None
        nameLabel.textColor = UIColor.paletteDCMainColor()
        self.layoutIfNeeded()
        avatar.setCornerRadius(avatar.bounds.midX)
        deleteButton.setTitle("删除", forState: UIControlState.Normal)
        commentButtonLabel.text = "评论"
        scoreStarsView.backgroundColor = UIColor.clearColor()
        titleStarsView.backgroundColor = UIColor.clearColor()
        
        imagesBottomConstraint = NSLayoutConstraint(item: imagesView, attribute: .Bottom, relatedBy: .Equal, toItem: imagesView, attribute: .Top, multiplier: 1, constant: 0)
        imagesView.addConstraint(imagesBottomConstraint)
        
        for view in imagesView.subviews {
            if let imageView = view as? UIImageView {
                imageView.userInteractionEnabled = true
                let singleTap = UITapGestureRecognizer(target: self, action: #selector(CircleCell.tapImage(_:)))
                imageView.addGestureRecognizer(singleTap)
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.sd_cancelCurrentImageLoad()
        avatar.image = nil
    }
    
    func updateLabelsPreferredMaxLayoutWidth() {
        contentLabel.preferredMaxLayoutWidth = contentLabel.frame.width
        for label in commentLabels {
            label.preferredMaxLayoutWidth = label.frame.width
        }
    }

    // MARK: - Action
    @IBAction func clickedLikeButton(sender: UIButton) {
        let like = !sender.selected
        delegate?.cellDidClickedLikeButton(self, like: like)
    }
    
    func clickedLikeBar(sender: AnyObject) {
        delegate?.cellDidClickedLikeBar(self)
    }
    
    @IBAction func clickedCommentButton(sender: AnyObject) {
        delegate?.cellDidClickedCommentButton(self)
    }

    @IBAction func clickedDeleteButton(sender: AnyObject) {
        delegate?.cellDidClickedDeleteButton(self)
    }
    
    func clickedMoreButton(sender: AnyObject) {
        
    }
    
    func tapImage(sender: UITapGestureRecognizer) {
        guard sender.state == .Ended, let imageView = sender.view as? UIImageView else {
            return
        }
        if let index = imagesView.subviews.indexOf(imageView) {
            delegate?.cellDidClickedImage(self, imageView: imageView, index: index)
        }
    }
    
    // MARK: - 
    func setupWithArticle(article: DCArticle) {
 //       avatar.isLoad = true
//        avatar.sd_setImageWithURL(article.avatarURL, placeholderImage: UIImage(named: "default_user_avatar_gray"))
        avatar.hssy_sd_setImageWithURL(article.avatarURL, placeholderImage: UIImage(named: "default_user_avatar_gray"))
        nameLabel.textColor = UIColor.paletteDCMainColor()
        nameLabel.text = article.userName
        
        let city = DCArea.findCityByCityId(article.cityId)
        if let location = city.name {
            locationView.hidden = false
            if location.characters.count > 0 {
                locationLabel.text = location
            } else {
                locationLabel.text = "未知"
            }
        } else {
            locationView.hidden = true
        }
        
//        timeLabel.text = NSDateFormatter.circleArticleDateFormatter().stringFromDate(article.time)
        timeLabel.text = NSDate.stringDateFromNow(article.createTime)
        contentLabel.text = article.content
        
        // Images
        imagesView.removeConstraint(imagesBottomConstraint)
        imagesBottomConstraint = NSLayoutConstraint(item: imagesView, attribute: .Bottom, relatedBy: .Equal, toItem: imagesView, attribute: .Top, multiplier: 1, constant: 0)
        imagesView.addConstraint(imagesBottomConstraint)
        
        for (index, imageView) in imagesView.subviews.enumerate() {
            let imageView = imageView as! UIImageView
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            
            if index < article.images.count {
                let image = article.images[index] as! String
                imageView.hidden = false
                imageView.isLoad = false
                imageView.hssy_sd_setImageWithURL(NSURL(imagePath: image), placeholderImage: UIImage(named: "default_pile_image_short"))
                
                imagesView.removeConstraint(imagesBottomConstraint)
                imagesBottomConstraint = NSLayoutConstraint(item: imagesView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0)
                imagesView.addConstraint(imagesBottomConstraint)
            } else {
                imageView.hidden = true
            }
        }
        
        // Like
        likeButton.selected = article.like
        
        commentView.removeAllSubviews()
        var commentSubviews: [UIView] = []
        if article.likes.count > 0 {
            let likeBarView = ImagesBar()
            likeBarView.addConstraintWithHeight(32)
            commentSubviews.append(likeBarView)
            likeBarView.setImageURLs(article.likeAvatarURLs as! [NSURL], placeholderImage: UIImage(named: "default_user_avatar_gray"))
            likeBarView.addTarget(self, action: #selector(CircleCell.clickedLikeBar(_:)), forControlEvents: .TouchUpInside)
            likeBar = likeBarView
        }
        if article.likeCount > 0 {
            likeNumberLabel.text = "\(article.likeCount)"
        } else {
            likeNumberLabel.text = nil
        }
        
        // Comment
        commentLabels = []
        let commentShowNumber = 3
        for (index, comment) in article.comments.enumerate() {
            if index >= commentShowNumber {
                break;
            }
            if let comment = comment as? DCArticleComment {
                let label = InteractiveLabel()
                label.numberOfLines = 0
                label.font = UIFont.systemFontOfSize(13)
                
                let attributedText = NSMutableAttributedString(string: comment.userName, attributes: [NSForegroundColorAttributeName: UIColor.paletteDCMainColor()])
                if comment.replyUserId != nil {
                    let replyName = comment.replyUserName ?? "匿名"
                    attributedText.appendAttributedString(NSAttributedString(string: " 回复 ", attributes: [NSForegroundColorAttributeName: UIColor.paletteFontDarkGrayColor()]))
                    attributedText.appendAttributedString(NSAttributedString(string: replyName, attributes: [NSForegroundColorAttributeName: UIColor.paletteDCMainColor()]))
                }
                attributedText.appendAttributedString(NSAttributedString(string: ": ", attributes: [NSForegroundColorAttributeName: UIColor.paletteFontDarkGrayColor()]))
                attributedText.appendAttributedString(NSAttributedString(string: comment.content, attributes: [NSForegroundColorAttributeName: UIColor.paletteFontDarkGrayColor()]))
                label.attributedText = attributedText
                
                label.singleTapHandler = { [unowned self] _ in
                    self.delegate?.cellDidClickedCommentLabel(self, comment: comment)
                }
                
                commentLabels.append(label)
                commentSubviews.append(label)
            }
        }
        if article.comments.count >= commentShowNumber && article.commentCount > commentShowNumber {
            let moreCommentButton = UIButton()
            moreCommentButton.userInteractionEnabled = false
            moreCommentButton.addConstraintWithHeight(18)
            moreCommentButton.titleLabel?.font = UIFont.systemFontOfSize(13)
            moreCommentButton.setTitleColor(UIColor.paletteFontDarkGrayColor(), forState: UIControlState.Normal)
            moreCommentButton.setTitle("查看更多（\(article.commentCount - commentShowNumber)）", forState: UIControlState.Normal)
            moreCommentButton.addTarget(self, action: #selector(CircleCell.clickedMoreButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            commentSubviews.append(moreCommentButton)
            moreButton = moreCommentButton
        }
        
        commentView.addSubviewsWithTableLayout(commentSubviews, spacing: 8)
        
        // Delete
        deleteButton.hidden = !article.userArticle
        deleteButtonHeightCons.constant = deleteButton.hidden ? 8 : 30
        
        // Evaluate
        scoreLabel.hidden = true
        scoreStarsView.hidden = true
        titleStarsView.hidden = true
    }
    
    func setupEvaluation(article: DCArticle, withPrefix: Bool) {
        if article.type == .Evaluate {
            contentLabel.text = article.content
            if let stationName = article.stationName, stationId = article.stationId, content = article.content {
                if withPrefix {
                    let prefixString = "#充电体验# 来了"
                    let contentString = "\(prefixString)\(stationName)，\(content)"
                    contentLabel.text = contentString
                    
                    contentLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.paletteDCMainColor()];
                    contentLabel.activeLinkAttributes = [kCTForegroundColorAttributeName: UIColor.paletteFontDarkGrayColor()];
                    let link = contentLabel.addLinkToURL(NSURL(string: "pole:\(stationId)"), withRange: NSMakeRange(prefixString.characters.count, stationName.characters.count))
                    link.linkTapBlock = { [unowned self] _ in
                        self.delegate?.cellDidClickedStation(stationId, type: article.type)
                    }
                }
            }
            
            // Stars
            if let score = article.starScore?.integerValue {
                scoreLabel.hidden = false
                scoreStarsView.hidden = false
                scoreStarsView.setScore(Float(score))
            }
        }
    }
    
    func setupForMyEvaluation(article: DCArticle) {
        guard article.type == .Evaluate else {
            return
        }
        
        guard let pileName = article.stationName else {
            return
        }
        
        scoreLabel.hidden = true
        scoreStarsView.hidden = true
        locationView.hidden = true
        titleStarsView.hidden = false
        
//        avatar.sd_setImageWithURL(NSURL(imagePath: article.pileImage), placeholderImage: UIImage(named: "default_pile_image_short"))
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.text = pileName
    }
}

protocol CircleCellDelegate: class {
    func cellDidClickedLikeButton(cell: CircleCell, like: Bool)
    func cellDidClickedLikeBar(cell: CircleCell)
    func cellDidClickedCommentButton(cell: CircleCell)
    func cellDidClickedCommentLabel(cell: CircleCell, comment: DCArticleComment)
    func cellDidClickedStation(stationId: String, type:DCArticleType)
    func cellDidClickedImage(cell: CircleCell, imageView: UIImageView, index: Int)
    func cellDidClickedDeleteButton(cell: CircleCell)
}
