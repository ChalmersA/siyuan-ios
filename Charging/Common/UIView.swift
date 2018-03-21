//
//  UIView.swift
//  GuoBangCleaner
//
//  Created by Ben on 12/12/2015.
//  Copyright © 2015 com.xpg. All rights reserved.
//

import UIKit

extension UIView{
    
    ///圆角
    func setCornerRadius(){
        layer.mask?.masksToBounds = true
        layer.cornerRadius = 3
    }
    
    ///圆形
    func setRoundView(){
        layer.mask?.masksToBounds = true
        layer.cornerRadius = frame.size.height / 2.0
    }
    
    ///设置边框颜色
    ///- parameter color 边框颜色
    func setBorderColor(color: UIColor){
        layer.borderColor = color.CGColor
        layer.borderWidth = 0.5
    }
}
