//
//  Application.swift
//  Charging
//
//  Created by xpg on 6/24/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

extension UIApplication {
    struct Key {
        static let LaunchTime = "LaunchTime"
    }
    
    // MARK: Settings
    func openSettings() {
        if UIDevice.systemVersionLessThan8() {
            return
        }
        if #available(iOS 8.0, *) {
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                self.openURL(url)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func isNotificationEnabled() -> Bool {
        if UIDevice.systemVersionLessThan8() {
            return enabledRemoteNotificationTypes() != UIRemoteNotificationType.None
        }
        if #available(iOS 8.0, *) {
            return currentUserNotificationSettings()!.types != UIUserNotificationType.None
        } else {
            // Fallback on earlier versions
            return enabledRemoteNotificationTypes() != UIRemoteNotificationType.None
        }
    }
    
    func checkNotificationSetting() -> Bool {
        let enabled = isNotificationEnabled()
        if enabled == false {
            var buttons = ["好的", "设置"]
            if UIDevice.systemVersionLessThan8() {
                buttons = ["好的"]
            }
            let alert = UIAlertView.showAlertMessage("你现在无法收到消息通知，请到系统的“设置”-“通知”中更改设置", buttonTitles: buttons)
            alert.setClickedButtonHandler({ (index) -> Void in
                if index == 1 {
                    self.openSettings()
                }
            })
        }
        return enabled
    }
    
    // MARK: LaunchTime
    func saveLaunchTime() {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Key.LaunchTime)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func lastLaunchTime() -> NSDate? {
        return NSUserDefaults.standardUserDefaults().objectForKey(Key.LaunchTime) as? NSDate
    }
}

extension UIDevice {
    static func systemVersionLessThan8() -> Bool {
        return currentDevice().systemVersion.compare("8.0", options: .NumericSearch) == .OrderedAscending
    }
}
