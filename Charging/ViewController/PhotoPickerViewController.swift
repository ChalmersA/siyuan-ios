//
//  PhotoPickerViewController.swift
//  Charging
//
//  Created by xpg on 7/2/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class PhotoPickerViewController: MLSelectPhotoPickerViewController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func show() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        DCApp.sharedApp().rootViewController.presentViewController(self, animated: true, completion: nil)
    }
    
    func show(fromViewController: UIViewController) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        fromViewController.presentViewController(self, animated: true, completion: nil)
    }
}
