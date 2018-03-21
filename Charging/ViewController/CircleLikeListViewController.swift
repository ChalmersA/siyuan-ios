//
//  CircleLikeListViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/9/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class CircleLikeListViewController: DCViewController {

    var article: DCArticle!
    var nextPageIndex = 0
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // header
        let header = MJRefreshNormalHeader { [unowned self] in
            self.requestLikesWithPageIndex(1)
        }
        header.lastUpdatedTimeLabel?.hidden = true
        tableView.header = header
        
        // footer
        let footer = MJRefreshAutoNormalFooter { [unowned self] in
            self.requestLikesWithPageIndex(self.nextPageIndex)
        }
        footer.setTitle("没有更多", forState: MJRefreshStateNoMoreData)
        footer.hidden = true
        tableView.footer = footer
        tableView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    func requestLikesWithPageIndex(pageIndex: Int) {
        let hub = showHUDIndicator()
        CircleAPI.getArticleLikeList(article.articleId, page: pageIndex, pageSize: 20) { [weak weakSelf = self] (success, articleLikes, errorMessage) in
            guard let strongSelf = weakSelf else {
                return
            }
            if success {
                hub.hide(true)
                strongSelf.article.likes = articleLikes!
                
                self.nextPageIndex+=1
                
            } else {
                strongSelf.hideHUD(hub, withText: errorMessage)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CircleLikeListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return article.likes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LikeCell", forIndexPath: indexPath) as! LikeCell
        if let like = article.likes[indexPath.row] as? DCArticleLike {
            cell.setupWithLike(like)
        }
        return cell
    }
}
