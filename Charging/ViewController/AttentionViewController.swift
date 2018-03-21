//
//  AttentionViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/9/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class AttentionViewController: DCViewController {

    // MARK: -
    let viewControllerCount = 2
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topTabBar: ScrollBar!
    var pageViewController: UIPageViewController? {
        get {
            for child in childViewControllers {
                if let child = child as? UIPageViewController {
                    return child
                }
            }
            return nil
        }
    }
    
    var circleViewController: CircleViewController?
    var topicViewController: TopicViewController?
    var newsViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topView.backgroundColor = UIColor.paletteDCMainColor()
        
        let tabTitles = ["充电圈", "动态"]
        var buttons: [UIButton] = []
        for title in tabTitles {
            let button = UIButton(type: .Custom)
            button.setTitle(title, forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            button.setTitleColor(UIColor(white: 1, alpha: 0.6), forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
            buttons.append(button)
        }
        topTabBar.setButtons(buttons, displayCount: 2)
        topTabBar.didClickedButtonHandler = {
            [unowned self] index in
            if let viewController = self.viewControllerForIndex(index) {
                self.pageViewController?.setViewControllers([viewController], direction: .Forward, animated: false, completion: nil)
            }
        }
        
        
        let initialIndex = 0
        topTabBar.selectIndex(initialIndex)
        
        if let pageViewController = pageViewController {
//            pageViewController.dataSource = self
            if let viewController = viewControllerForIndex(initialIndex) {
                pageViewController.setViewControllers([viewController], direction: .Forward, animated: false, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
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
    
    // MARK: -
    
    func viewControllerForIndex(index: Int) -> UIViewController? {
        switch index {
        case 0:
            if circleViewController == nil {
                circleViewController = CircleViewController.storyboardInstantiate()
            }
            return circleViewController
            
        case 1:
            if newsViewController == nil {
                newsViewController = UIStoryboard(name: "Attention", bundle: nil).instantiateViewControllerWithIdentifier("TrendViewController")
            }
            return newsViewController
            
        default:
            return nil
        }
    }
}

//extension AttentionViewController: UIPageViewControllerDataSource {
//    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
//        if let index = viewController.title?.toInt() {
//            return self.viewControllerForIndex(index + 1)
//        }
//        return nil
//    }
//    
//    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
//        if let index = viewController.title?.toInt() {
//            return self.viewControllerForIndex(index - 1)
//        }
//        return nil
//    }
//}
