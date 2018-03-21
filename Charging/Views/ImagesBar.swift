//
//  ImagesBar.swift
//  Charging
//
//  Created by chenzhibin on 15/9/16.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class ImagesBar: UIControl {

    var imageSize = CGSize(width: 24, height: 24)
    var spacing: CGFloat = 4
    var imageViews: [UIImageView] = []
    lazy var moreImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "circle_more"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        return imageView
    }()
    
    override func layoutSubviews() {
        UIView.performWithoutAnimation({ () -> Void in
            super.layoutSubviews()
            
            let bounds = self.bounds
            let imageSize = self.imageSize
            
            var frame = CGRect(x: 0, y: (bounds.height - imageSize.height) / 2.0, width: imageSize.width, height: imageSize.height)
            var firstHiddenImageView: UIImageView? = nil
            for (index, imageView) in self.imageViews.enumerate() {
                if frame.maxX > bounds.maxX {
                    imageView.hidden = true
                    if firstHiddenImageView == nil {
                        if index == 0 {
                            firstHiddenImageView = imageView
                        } else {
                            firstHiddenImageView = self.imageViews[index - 1]
                            firstHiddenImageView?.hidden = true
                        }
                    }
                } else {
                    imageView.hidden = false
                    imageView.frame = frame
                    frame.origin.x = frame.maxX + self.spacing
                }
            }
            
            self.moreImageView.removeFromSuperview()
            if firstHiddenImageView != nil {
                self.addSubview(self.moreImageView)
                self.moreImageView.frame = CGRect(x: bounds.maxX - imageSize.width, y: (bounds.height - imageSize.height) / 2.0, width: imageSize.width, height: imageSize.height)
            }
        })
    }
    
    func setImageURLs(URLs: [NSURL], placeholderImage: UIImage?) {
        for view in imageViews {
            view.removeFromSuperview()
        }
        imageViews = []
        for url in URLs {
            let imageView = UIImageView()
            imageView.setCornerRadius(imageSize.width / 2.0)
            imageView.isLoad = false
            imageView.hssy_sd_setImageWithURL(url, placeholderImage: placeholderImage)
            imageViews.append(imageView)
            addSubview(imageView)
        }
        setNeedsLayout()
    }

}
