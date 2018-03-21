//
//  CircleViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/9/10.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class CircleViewController: SLKTextViewController {
    
    enum HSSYAlertViewType: Int {
        case HSSYAlertViewTypeComment = 0
        case HSSYAlertViewTypeCircleArticle = 1
    }
    
    var articles: [DCArticle] = []
    var nextPageIndex = 1
    
    var actionIndexPath: NSIndexPath?
    var replyComment: DCArticleComment?
    let pushToArticleDetailSegueId = "PushToArticleDetail"
    let pushToLikeListSegueId = "PushToLikeList"
    let presentCircleSendSegueId = "PresentCircleSend"
    var articleIndex = Int()
    var articleDelete: DCArticle?
    var articleDeleteMessage: String {
        return "是否删除该条充电圈"
    }
    
    var prototypeCell: CircleCell?
    var alertViewType: HSSYAlertViewType?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.backBarItemWithTarget(self, action: #selector(CircleViewController.navigateBack(_:)))
        
        // UITableView
        tableView.registerNib(UINib(nibName: "CircleCell", bundle: nil), forCellReuseIdentifier: "CircleCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        // header
        let header = MJRefreshNormalHeader { [unowned self] in
            self.fetchArticlesWithPageIndex(1)
        }
        header.lastUpdatedTimeLabel?.hidden = true
        tableView.header = header
        
        // footer
        let footer = MJRefreshAutoNormalFooter { [unowned self] in
            self.fetchArticlesWithPageIndex(self.nextPageIndex)
        }
        footer.setTitle("没有更多", forState: MJRefreshStateNoMoreData)
        footer.hidden = true
        tableView.footer = footer
        tableView.tableFooterView = UIView()
        
        // SLKTextViewController
        inverted = false
        textInputbar.autoHideRightButton = false
        textInputbar.rightButton.layer.cornerRadius = 3
        textInputbar.rightButton.layer.masksToBounds = true
        textInputbar.rightButton.setTitle("回复", forState: UIControlState.Normal)
        textInputbar.rightButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        textInputbar.rightButton.backgroundColor = UIColor.paletteDCMainColor()
        textInputbarHidden = true
        textView.placeholder = "发表一下您的评论..."
        
        // subviews
        view.sendSubviewToBack(tableView)
        
//        articles = [HSSYArticle.debugArticle(), HSSYArticle.debugArticle()]
        
        // Layout
        reloadTableView()
        
        header.beginRefreshing()
        
        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CircleViewController.articleDidChange(_:)), name: CircleArticleViewController.articleDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CircleViewController.articleDidDelete(_:)), name: CircleArticleViewController.articleDidDeleteNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CircleViewController.userDidChange(_:)), name: NOTIFICATION_USER_DID_CHANGE, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getNewArctileFromCircleArticleVCClosure(newArticle: DCArticle) -> Void {
        // Function body goes here
        for article in articles {
            if article.articleId == newArticle.articleId {
                article.replaceArticle(newArticle)
                break
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == pushToArticleDetailSegueId {
            if let articleVC = segue.destinationViewController as? CircleArticleViewController {
                articleVC.initWithMyArticleClosure(getNewArctileFromCircleArticleVCClosure)
                articleVC.article = sender as! DCArticle
            }
        }
        else if segue.identifier == pushToLikeListSegueId {
            if let likeListVC = segue.destinationViewController as? CircleLikeListViewController {
                likeListVC.article = sender as! DCArticle
            }
        }
        else if segue.identifier == presentCircleSendSegueId {
            guard let sendNavVC = segue.destinationViewController as? UINavigationController else {
                return
            }
            guard let sendVC = sendNavVC.viewControllers.first as? CircleSendViewController else {
                return
            }
            
            sendVC.delegate = self
        }
    }
    
    @IBAction func presentSendView(sender: AnyObject) {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
        performSegueWithIdentifier(presentCircleSendSegueId, sender: sender)
    }
    
    func navigateBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Request
    func fetchArticlesWithPageIndex(pageIndex: Int) {
        let hud = showHUDIndicator()
        
        CircleAPI.getArticleList(pageIndex, pageSize: 10, type: .AllArticle, userId: DCApp.sharedApp().user?.userId, stationId: nil) { (success, articles, errorMessage) in
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
                self.nextPageIndex+=1
                
                self.tableView.footer.hidden = (self.articles.count == 0)
                
                self.reloadTableView()
                hud.hide(true)
            } else {
                self.hideHUD(hud, withText: errorMessage)
            }
        }
    }

}

extension CircleViewController {
    override func didPressRightButton(sender: AnyObject!) {
        let content = textView.text
        super.didPressRightButton(sender)
        self.dismissKeyboard(true)
        
        guard let indexPath = actionIndexPath, let userId = DCApp.sharedApp().user?.userId else {
            return
        }
        
        let article = articles[indexPath.row]
        let hub = showHUDIndicator()
        
        CircleAPI.commentArticle(article.articleId, content: content, userId: userId, replyCommentId: replyComment?.commentId) { (success, errorMessage) in
            if success {
                
                CircleAPI.getArticleInfo(article.articleId, userId: userId, completion: { (responseCode, success, latestArticle, errorMessage) in
                    if success {
                        hub.hide(true)
                        article.replaceArticle(latestArticle!)
                        self.tableView.reloadData();
                        
                    } else {
                        self.hideHUD(hub, withText: errorMessage)
                    }
                })
                
            } else {
                self.hideHUD(hub, withText: errorMessage)
            }
        }
        
//        CircleAPI.commentArticle(article.articleId, content: content, userId: user.userId, replyId: replyComment?.commentId, replyUserId: replyComment?.userId,
//            completion: { (success, errorMessage) -> Void in
//                if success {
//                    hub.hide(true)
//                    
//                    CircleAPI.getArticleInfo(article.articleId, userId: user.userId, completion: { (success, article, errorMessage) in
//                        if success {
//                            let orgArtIndex:NSInteger = self.articles.indexOf(article!)!
//                            if orgArtIndex >= 0 {
//                                article!.replaceArticle(article!)
//                                self.tableView.reloadData();
//                            }
//                        } else {
//                            self.hideHUD(hub, withText: errorMessage)
//                        }
//                    })
//
//                } else {
//                    self.hideHUD(hub, withText: errorMessage)
//                }
//        })
        
    }
    
    override func textViewDidBeginEditing(textView: UITextView) {
        textInputbarHidden = false
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        textInputbarHidden = true
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dismissKeyboard(true)
    }
    
    override func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        dismissKeyboard(true)
        return true
    }
}

extension CircleViewController: CircleCellDelegate {
    func cellDidClickedImage(cell: CircleCell, imageView: UIImageView, index: Int) {
        
        dismissKeyboard(true)
        guard let indexPath = tableView.indexPathForCell(cell) else {
            return
        }
        let article = articles[indexPath.row]
        var images = [KZImage]()
        for imagePath in article.images as! [String] {
            let image = KZImage(URL: NSURL(imagePath: imagePath))
//            image.thumbnailImage = UIImage(named: "default_pile_image_short")
            images.append(image)
        }
        
        let imageViewer = KZImageViewer()
        imageViewer.showImages(images, selectImageView: imageView, atIndex: index)
    }
    
    func cellDidClickedLikeButton(cell: CircleCell, like: Bool) {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
        
        if let indexPath = tableView.indexPathForCell(cell) {
            let article = articles[indexPath.row]
            let userId = DCApp.sharedApp().user.userId
            
            let hub = showHUDIndicator()
            CircleAPI.likeArticle(article.articleId, like: like, userId: userId, completion: { (success, errorMessage) -> Void in
                if success {
                    hub.hide(true)
                    if like {
                        article.addCurrentUserLike()
                    } else {
                        article.deleteCurrentUserLike()
                    }
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                } else {
                    self.hideHUD(hub, withText: errorMessage)
                }
            })
        }

    }
    
    func cellDidClickedLikeBar(cell: CircleCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let article = articles[indexPath.row]
            performSegueWithIdentifier(pushToLikeListSegueId, sender: article)
        }
    }
    
    func cellDidClickedCommentButton(cell: CircleCell) {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
        
        actionIndexPath = tableView.indexPathForCell(cell)
        if let indexPath = actionIndexPath {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
        }
        
        replyComment = nil
        textView.placeholder = "发表一下您的评论..."
//        textView.text = nil
        presentKeyboard(true)
    }
    
    func cellDidClickedCommentLabel(cell: CircleCell, comment: DCArticleComment) {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
        
        actionIndexPath = tableView.indexPathForCell(cell)
        
        articleIndex = (tableView.indexPathForCell(cell)?.row)!
        if let indexPath = actionIndexPath {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
        }
        
        replyComment = comment
        
        if comment.userId == DCApp.sharedApp().user.userId {
            let alert = UIAlertView(title: nil, message: "是否删除该条评论？", delegate: self, cancelButtonTitle: "取消")
            alert.tag = HSSYAlertViewType.HSSYAlertViewTypeComment.rawValue
            alert.addButtonWithTitle("确定")
            alert.show()
            alert.setClickedButtonHandler({ (index) -> Void in
                if index == 1 {
                    let hud = self.showHUDIndicator()
                    CircleAPI.postForDeleteMyComment(DCApp.sharedApp().user.userId, commentId: self.replyComment!.commentId, completion: { (success, errorMessage) -> Void in
                        if success {
                            hud.hide(true)
                            let mutableComments = (self.articles[self.articleIndex].comments as NSArray).mutableCopy()
                            mutableComments.removeObject(self.replyComment!)
                            self.articles[self.articleIndex].comments = mutableComments as! [AnyObject];
                            self.tableView.reloadData()
                        } else {
                            self.hideHUD(hud, withText: errorMessage)
                        }
                    })
                }
            })
        } else {
            textView.placeholder = "@\(comment.userName):"
            //        textView.text = nil
            presentKeyboard(true)
        }
    }

    func cellDidClickedStation(stationId: String, type: DCArticleType) {
        let stationDetailVC = DCStationDetailViewController.storyboardInstantiate()
        let station = DCStation()
        station.stationId = stationId
        stationDetailVC.selectStationInfo = station
        navigationController?.pushViewController(stationDetailVC, animated: true)
    }
      
    func cellDidClickedDeleteButton(cell: CircleCell) {
        if let indexPath_Delete = tableView.indexPathForCell(cell) {
            articleDelete = articles[indexPath_Delete.row]
            
            if self.presentLoginViewIfNeededCompletion(nil) {
                return
            }
            
            let alert = UIAlertView(title: nil, message: articleDeleteMessage, delegate: self, cancelButtonTitle: "取消")
            alert.tag = HSSYAlertViewType.HSSYAlertViewTypeCircleArticle.rawValue
            alert.addButtonWithTitle("确定")
            alert.show()
            alert.setClickedButtonHandler({ (index) -> Void in
                if index == 1 {
                    let hud = self.showHUDIndicator()
                    CircleAPI.deleteArticle(self.articleDelete!.articleId, userId: DCApp.sharedApp().user.userId, completion: { (success, errorMessage) -> Void in
                        if success {
                            hud.hide(true)
                            self.articles.removeAtIndex(self.articles.indexOf(self.articleDelete!)!)
                            self.reloadTableView()
                        } else {
                            self.hideHUD(hud, withText: errorMessage)
                        }
                    })
                }
            })
        }
    }
}

extension CircleViewController {
    func reloadTableView() {
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CircleCell", forIndexPath: indexPath) as! CircleCell
        let article = articles[indexPath.row]
        cell.setupWithArticle(article)
        cell.setupEvaluation(article, withPrefix: true)
        cell.delegate = self
        return cell
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if prototypeCell == nil {
//            prototypeCell = tableView.dequeueReusableCellWithIdentifier("CircleCell") as? CircleCell
//        }
//        if let cell = prototypeCell {
//            cell.frame.size.width = view.bounds.width
//            cell.setupWithArticle(HSSYArticle.debugArticle())
//            cell.layoutIfNeeded()
//            
//            cell.updateLabelsPreferredMaxLayoutWidth()
//
//            cell.layoutIfNeeded()
//            let height = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//            print("cell height \(height)\n")
//            return height + 1
//        }
//        return 0
//    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let article = articles[indexPath.row]
        performSegueWithIdentifier(pushToArticleDetailSegueId, sender: article)
    }
}

extension CircleViewController: CircleSendViewControllerDelegate {
    func circleArticleDidSend() {
        tableView.header.beginRefreshing()
    }
}

// MARK: - NSNotification
extension CircleViewController {
    func articleDidChange(notification: NSNotification) {
        guard let changedArticle = notification.object as? DCArticle else {
            return
        }
        for (index, article) in articles.enumerate() {
            if article.articleId == changedArticle.articleId {
                articles[index] = changedArticle
                reloadTableView()
                break
            }
        }
    }
    
    func articleDidDelete(notification: NSNotification) {
        guard let changedArticle = notification.object as? DCArticle else {
            return
        }
        for (index, article) in articles.enumerate() {
            if article.articleId == changedArticle.articleId {
                articles.removeAtIndex(index)
                reloadTableView()
                break
            }
        }
    }
    
    func userDidChange(notification: NSNotification) {
        reloadTableView()
    }
}

// MARK: - Storyboard
extension CircleViewController {
    override class func storyboardInstantiate() -> CircleViewController {
        return UIStoryboard(name: "Attention", bundle: nil).instantiateViewControllerWithIdentifier("CircleViewController") as! CircleViewController
    }
}
