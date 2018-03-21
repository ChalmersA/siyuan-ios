//
//  HelpViewController.swift
//  Charging
//
//  Created by xpg on 6/9/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class HelpViewController: UITableViewController {
    
    @IBOutlet weak var topView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        topView.backgroundColor = UIColor.paletteDCMainColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
//            performSegueWithIdentifier("PushToQAView", sender: indexPath)
            performSegueWithIdentifier("PushToAnswer", sender: indexPath)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         if segue.identifier == "PushToQAView" {
            if let vc = segue.destinationViewController as? QAViewController {
                vc.questionIndex = sender as? NSIndexPath
            }
         } else if segue.identifier == "PushToAnswer" {
            if let vc = segue.destinationViewController as? AnswerViewController {
                vc.index = sender as? NSIndexPath
            }
        }
    }
    
    // MARK: - Action
    @IBAction func navigationBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func callHotline(sender: AnyObject) {
//        DCApp.sharedApp().callPhone("021-616-10101")
        DCApp.sharedApp().callPhone("021-616-10101", viewController:self)
    }
}
