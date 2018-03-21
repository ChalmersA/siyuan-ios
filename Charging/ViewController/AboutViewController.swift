//
//  AboutViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/10/19.
//  Copyright © 2015年 xpg. All rights reserved.
//

import UIKit

class AboutViewController: DCViewController {
    @IBOutlet weak var versionClicker: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    
    var versionShowTimes:NSInteger = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        let versionClickSelector =  #selector(AboutViewController.versionClickerTapped(_:))
        if self.respondsToSelector(versionClickSelector) {
            let gestRecognizer = UITapGestureRecognizer(target: self, action: versionClickSelector)
            gestRecognizer.numberOfTapsRequired = 6
            versionClicker.addGestureRecognizer(gestRecognizer)
        }
        
        versionLabel.text = appVersion()
        
//        let hud = self.showHUDIndicator()
        
//        DCSiteApi.getUpdateMessageWithCompletion { [weak weakSelf = self] (task, success, response, error) in
//            guard let strongSelf = weakSelf else {
//                return
//            }
//            if !success || !response.isSuccess() {
//                strongSelf.hideHUD(hud, withText: DCWebResponse.errorMessage(error, withResponse: response))
//                return
//            }
//            else {
//                let dict = response.result as! NSDictionary
//                let imageURLstring = dict.objectForKey("appQrcode")
//                if imageURLstring != nil {
//                    let imageURL = NSURL(string: imageURLstring as! String)
//                }
//                
//            }
//            hud.hide(true)
//
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

//    @IBAction func rateApp(sender: AnyObject) {
////        UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id981007045")!)
//        UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=981007045&type=Purple+Software")!)
//    }
    
    
    func versionClickerTapped(sender:UITapGestureRecognizer) {
        versionShowTimes += 1
        var versionInfoStr:String = appVersion() + "\n" + appBuildVersion() + "\n" + serverURL()
        if versionShowTimes > 3 {
           versionInfoStr = versionInfoStr + "\n" + appGitInfo()
        }
        UIAlertView.showAlertMessage(versionInfoStr, title:"版本信息", buttonTitles: ["确定"])
    }
}
