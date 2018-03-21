//
//  ArticleContentCell.swift
//  Charging
//
//  Created by chenzhibin on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class ArticleContentCell: UITableViewCell {

    weak var delegate: ArticleContentCellDelegate?
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var imagesView: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreStarsView: FiveStarsView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var arrowView: UIView!
    
    var imagesBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.None
        arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        
        nameLabel.textColor = UIColor.paletteDCMainColor()
        self.layoutIfNeeded()
        avatar.setCornerRadius(avatar.bounds.midX)
        deleteButton.setTitle("删除", forState: UIControlState.Normal)
        
        imagesBottomConstraint = NSLayoutConstraint(item: imagesView, attribute: .Bottom, relatedBy: .Equal, toItem: imagesView, attribute: .Top, multiplier: 1, constant: 0)
        imagesView.addConstraint(imagesBottomConstraint)
        
        for view in imagesView.subviews {
            if let imageView = view as? UIImageView {
                imageView.userInteractionEnabled = true
                let singleTap = UITapGestureRecognizer(target: self, action: #selector(ArticleContentCell.tapImage(_:)))
                imageView.addGestureRecognizer(singleTap)
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Action
    @IBAction func deleteArticle(sender: AnyObject) {
        delegate?.deleteArticle()
    }
    
    @IBAction func likeArticle(sender: UIButton) {
        let like = !sender.selected
        delegate?.likeArticle(like)
    }
    
    func tapImage(sender: UITapGestureRecognizer) {
        guard sender.state == .Ended, let imageView = sender.view as? UIImageView else {
            return
        }
        if let index = imagesView.subviews.indexOf(imageView) {
            delegate?.clickedImage(imageView, index: index)
        }
    }
    
    // MARK: -
    func setupWithArticle(article: DCArticle) {
   //     avatar.isLoad = true
        avatar.hssy_sd_setImageWithURL(article.avatarURL, placeholderImage: UIImage(named: "default_user_avatar_gray"))
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
        
        if article.likeCount > 0 {
            likeNumberLabel.text = "\(article.likeCount)"
        } else {
            likeNumberLabel.text = nil
        }
        
        // Evaluate
        scoreLabel.hidden = true
        scoreStarsView.hidden = true
        if article.type == .Evaluate {
            if let stationName = article.stationName, stationId = article.stationId, content = article.content {
                let prefixString = "#充电体验# 来了"
                let contentString = "\(prefixString)\(stationName)，\(content)"
                contentLabel.text = contentString
                
                contentLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.paletteDCMainColor()];
                contentLabel.activeLinkAttributes = [kCTForegroundColorAttributeName: UIColor.paletteFontDarkGrayColor()];
                let link = contentLabel.addLinkToURL(NSURL(string: "pole:\(stationId)"), withRange: NSMakeRange(prefixString.characters.count, stationName.characters.count))
                link.linkTapBlock = { [unowned self] _ in
                    self.delegate?.clickedStation(stationId)
                }
                
                // Stars
                if let score = article.starScore?.integerValue {
                    scoreLabel.hidden = false
                    scoreStarsView.hidden = false
                    scoreStarsView.setScore(Float(score))
                }
            }
        }
        
        // Delete
        deleteButton.hidden = !article.userArticle
        
        // Comment Arrow
        if article.likes.count > 0 || article.comments.count > 0 {
            arrowView.hidden = false
        } else {
            arrowView.hidden = true
        }
    }
}

protocol ArticleContentCellDelegate: class {
    func deleteArticle()
    func likeArticle(like: Bool)
    func clickedStation(stationId: String)
    func clickedImage(imageView: UIImageView, index: Int)
}
