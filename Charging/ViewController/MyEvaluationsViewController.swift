//
//  MyEvaluationsViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/10/9.
//  Copyright © 2015年 xpg. All rights reserved.
//

import UIKit

class MyEvaluationsViewController: CircleViewController {

    override var articleDeleteMessage: String {
        return "是否删除该条评价"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        // Do any additional setup after loading the view.
        title = "我的所有评价"
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
    
    // MARK: - Request
    override func fetchArticlesWithPageIndex(pageIndex: Int) {
        guard let userId = DCApp.sharedApp().user?.userId else {
            showHUDText("请先登录")
            return
        }
        
        let hud = showHUDIndicator()
        
        CircleAPI.getArticleList(pageIndex, pageSize: 10, type: .MyEvaluate, userId: userId, stationId: nil) { (success, articles, errorMessage) in
            self.tableView.header.endRefreshing()
            self.tableView.footer.endRefreshing()
            if success {
                let articles = articles ?? []
                if articles.count < CircleAPI.articlesNumberPerPage {
                    self.tableView.footer.noticeNoMoreData()
                } else {
                    self.tableView.footer.resetNoMoreData()
                }
                
                if pageIndex == 1 {
                    self.nextPageIndex = 1
                    self.articles = []
                }
                self.articles += articles
                self.nextPageIndex += 1
                
                self.tableView.footer.hidden = (self.articles.count == 0)
                
                self.reloadTableView()
                hud.hide(true)
            } else {
                self.hideHUD(hud, withText: errorMessage)
            }
        }
    }

}

// MARK: - UITableView
extension MyEvaluationsViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CircleCell", forIndexPath: indexPath) as! CircleCell
        let article = articles[indexPath.row]
        cell.setupWithArticle(article)
        cell.setupEvaluation(article, withPrefix: true)
        cell.setupForMyEvaluation(article)
        cell.delegate = self
        return cell
    }
}

// MARK: - Storyboard
extension MyEvaluationsViewController {
    override class func storyboardInstantiate() -> MyEvaluationsViewController {
        return UIStoryboard(name: "Attention", bundle: nil).instantiateViewControllerWithIdentifier("MyEvaluationsViewController") as! MyEvaluationsViewController
    }
}

