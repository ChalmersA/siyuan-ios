//
//  AnswerViewController.swift
//  Charging
//
//  Created by xpg on 6/9/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class AnswerViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var question1: UIView!
    @IBOutlet weak var question2: UIView!
    @IBOutlet weak var question3: UIView!
    @IBOutlet weak var question4: UIView!
    @IBOutlet weak var question5: UIView!
    @IBOutlet weak var question6: UIView!
    
    var index: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(scrollView.frame)
        scrollView.layoutIfNeeded()
        if let indexPath = index {
            let views = [question1, question2, question3, question4, question5, question6]
            let rect = views[indexPath.row].frame;
            let rectlast = views[views.count-1].frame
            let pointLastView: CGPoint! = CGPointMake(rectlast.origin.x, rectlast.origin.y + rectlast.size.height)
            let scrollviewFrame: CGRect = scrollView.frame;
            if (pointLastView.y - rect.origin.y >= scrollviewFrame.size.height) {
                scrollView.setContentOffset(rect.origin, animated:false)
                //                scrollView.contentOffset = rect.origin;
            }
            else {
                scrollView.setContentOffset(CGPointMake(0, rectlast.origin.y + rectlast.size.height - scrollviewFrame.size.height), animated:false)
                //                scrollView.contentOffset = CGPointMake(0, rectlast.origin.y + rectlast.size.height - scrollviewFrame.size.height);
            }
            index = nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    @IBAction func navigationBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
