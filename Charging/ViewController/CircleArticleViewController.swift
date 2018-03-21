//
//  CircleArticleViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

typealias sendArticleClosure = (article: DCArticle) -> Void

class CircleArticleViewController: SLKTextViewController {

    enum HSSYAlertViewType: Int {
        case HSSYAlertViewTypeComment = 0
        case HSSYAlertViewTypeCircleArticle = 1
    }
    var article: DCArticle!
    var replyComment: DCArticleComment?
    var requestTask: NSURLSessionDataTask?
    var myArticleClosure: sendArticleClosure? //声明闭包
    var alertViewType: HSSYAlertViewType?
    
    @IBOutlet weak var commentButton: UIButton!
    
    let pushToLikeListSegueId = "PushToLikeList"
    static let articleDidChangeNotification = "CircleArticleDidChangeNotification"
    static let articleDidDeleteNotification = "CircleArticleDidDeleteNotification"
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }
    
    //这个方法需要传入上个界面的someFunctionThatTakesAClosure函数指针
    func initWithMyArticleClosure(closure: sendArticleClosure?) {
        myArticleClosure = closure  //将函数指针赋值给myArticleClosure闭包
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem.backBarItemWithTarget(self, action: #selector(CircleArticleViewController.navigateBack(_:)))
        commentButton.backgroundColor = UIColor.paletteDCMainColor()
        commentButton.setCornerRadius(4)
        
        tableView.registerNib(UINib(nibName: "ArticleContentCell", bundle: nil), forCellReuseIdentifier: "ArticleContentCell")
        tableView.registerNib(UINib(nibName: "ArticleLikeBarCell", bundle: nil), forCellReuseIdentifier: "ArticleLikeBarCell")
        tableView.registerNib(UINib(nibName: "ArticleCommentCell", bundle: nil), forCellReuseIdentifier: "ArticleCommentCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        view.sendSubviewToBack(tableView)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 74, 0)
        
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
        
        // Request
        let userId = DCApp.sharedApp().user?.userId
        
        CircleAPI.getArticleInfo(article.articleId, userId: userId) { [weak weakSelf = self] (responseCode, success, article, errorMessage) in
            guard let strongSelf = weakSelf else {
                return
            }
            
            if success {
                //获取评论列表替换article里的comment
                CircleAPI.getCommentList((article?.articleId)!, page: 1, pageSize: 20, completion: { (success, articleComments, errorMessage) in
                    
                    if success {
                        article?.comments = articleComments!
                        strongSelf.article = article
                        strongSelf.reloadTableView()
                    } else {
                        self.showHUDText("获取评论失败")
                        return
                    }
                })
                
            } else {
                if responseCode == RESPONSE_CODE_ARTICLE_UNEXIST {
                    strongSelf.showHUDText(errorMessage, completion: {
                        strongSelf.navigationController?.popViewControllerAnimated(true)
                    })
                } else {
                    strongSelf.showHUDText(errorMessage)
                }
            }
        }
        
        // Layout
        //        reloadTableView()
        
        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CircleArticleViewController.userDidChange(_:)), name: NOTIFICATION_USER_DID_CHANGE, object: nil)
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentViewController", object: self, userInfo: NSDictionary(object: self, forKey: "lastViewController") as [NSObject : AnyObject])
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    func navigateBack(sender: AnyObject?) {
        requestTask?.cancel()
        if presentingViewController != nil {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            actionForClosure()
            navigationController?.popViewControllerAnimated(true)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == pushToLikeListSegueId {
            if let likeListVC = segue.destinationViewController as? CircleLikeListViewController {
                likeListVC.article = sender as! DCArticle
            }
        }
    }

    // MARK: - Action
    
    @IBAction func commentAction(sender: AnyObject) {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
        
        replyComment = nil
        textView.placeholder = "发表一下您的评论..."
//        textView.text = nil
        presentKeyboard(true)
    }
    
    
    func replyComment(comment: DCArticleComment) {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
    
        replyComment = comment
        
        if comment.userId == DCApp.sharedApp().user.userId {
            let alert = UIAlertView(title: nil, message: "是否删除该条评论？", delegate: self, cancelButtonTitle: "取消")
            alert.tag = 0
            alert.addButtonWithTitle("确定")
            alert.show()
            alert.setClickedButtonHandler({ (index) -> Void in
                if index == 1 {
                    let hud = self.showHUDIndicator()
               self.requestTask = CircleAPI.postForDeleteMyComment(DCApp.sharedApp().user.userId, commentId: (self.replyComment?.commentId)!, completion: { (success, errorMessage) -> Void in
                        if success {
                            hud.hide(true)
                            let mutableComments = (self.article.comments as NSArray).mutableCopy()
                            mutableComments.removeObject(self.replyComment!)
                            self.article.comments = mutableComments as! [AnyObject];
                            self.tableView.reloadData()
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(CircleArticleViewController.articleDidChangeNotification, object: self.article)
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
    
    func actionForClosure() {
        if (myArticleClosure != nil) {
            myArticleClosure!(article: self.article)
        }
    }
}

extension CircleArticleViewController {
    override func didPressRightButton(sender: AnyObject!) {
        let content = textView.text
        super.didPressRightButton(sender)
        self.dismissKeyboard(true)
        
        guard let article = article, let userId = DCApp.sharedApp().user?.userId else {
            return
        }
        
        let requestReplyComment = replyComment
        
        let hub = showHUDIndicator()
        
        requestTask = CircleAPI.commentArticle(article.articleId, content: content, userId: userId, replyCommentId: requestReplyComment?.commentId, completion: { [weak weakSelf = self] (success, errorMessage) in
            if success {
                
                //获取评论列表替换article里的comment
                CircleAPI.getCommentList((article.articleId), page: 1, pageSize: 20, completion: { (success, articleComments, errorMessage) in
                    
                    if success {
                        article.comments = articleComments!
                        article.replaceArticle(article)
                        self.tableView.reloadData()
                        self.hideHUD(hub, withText: errorMessage)
                    } else {
                        self.showHUDText("获取评论失败")
                        return
                    }
                })
                
                NSNotificationCenter.defaultCenter().postNotificationName(CircleArticleViewController.articleDidChangeNotification, object: article)
            } else {
                weakSelf?.hideHUD(hub, withText: errorMessage)
            }
        })
        
//        requestTask = CircleAPI.commentArticle(article.articleId, content: content, userId: userId, replyId: requestReplyComment?.commentId, replyUserId: requestReplyComment?.userId,
//            completion: { [weak weakSelf = self] (success, errorMessage) -> Void in
//                if success {
//                    
//                    CircleAPI.getArticleInfo(article.articleId, userId: userId, completion: { (success, article, errorMessage) in
//                        if success {
//                            hub.hide(true)
//                            
//                            //获取评论列表替换article里的comment
//                            CircleAPI.getCommentList((article?.articleId)!, page: 1, pageSize: 20, completion: { (success, articleComments, errorMessage) in
//                                
//                                if success {
//                                    article?.comments = articleComments!
//                                } else {
//                                    self.showHUDText("获取评论失败")
//                                    return
//                                }
//                            })
//                            
//                            article!.replaceArticle(article!)
//                            self.tableView.reloadData()
//                        } else {
//                            self.hideHUD(hub, withText: errorMessage)
//                        }
//                        
//                    })
//                    
//                    NSNotificationCenter.defaultCenter().postNotificationName(CircleArticleViewController.articleDidChangeNotification, object: article)
//                } else {
//                    weakSelf?.hideHUD(hub, withText: errorMessage)
//                }
//            })
        
        dismissKeyboard(true)
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

extension CircleArticleViewController: ArticleContentCellDelegate {
    func deleteArticle() {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
        guard let article = article, let userId = DCApp.sharedApp().user?.userId else {
            return
        }
        guard userId == article.userId else {
            return
        }
        
        let alert = UIAlertView(title: nil, message: "是否删除该条充电圈？", delegate: self, cancelButtonTitle: "取消")
        alert.tag = 0
        alert.addButtonWithTitle("确定")
        alert.show()
        alert.setClickedButtonHandler { (index) -> Void in
            if index == 1 {
                let hud = self.showHUDIndicator()
                self.requestTask = CircleAPI.deleteArticle(article.articleId, userId: userId, completion: { [weak weakSelf = self] (success, errorMessage) -> Void in
                    if success {
                        hud.hide(true)
                        NSNotificationCenter.defaultCenter().postNotificationName(CircleArticleViewController.articleDidDeleteNotification, object: weakSelf!.article)
                        weakSelf?.navigateBack(nil)
                    } else {
                        weakSelf?.hideHUD(hud, withText: errorMessage)
                    }
                })
            }
        }
    }
    
    func likeArticle(like: Bool) {
        if self.presentLoginViewIfNeededCompletion(nil) {
            return
        }
        guard let article = article, let userId = DCApp.sharedApp().user?.userId else {
            return
        }
        
        let hub = showHUDIndicator()
        requestTask = CircleAPI.likeArticle(article.articleId, like: like, userId: userId, completion: { [weak weakSelf = self] (success, errorMessage) -> Void in
            if success {
                hub.hide(true)
                if like {
                    article.addCurrentUserLike()
                } else {
                    article.deleteCurrentUserLike()
                }
                weakSelf?.reloadTableView()
                
                NSNotificationCenter.defaultCenter().postNotificationName(CircleArticleViewController.articleDidChangeNotification, object: article)
            } else {
                weakSelf?.hideHUD(hub, withText: errorMessage)
            }
        })
    }
    
    func clickedStation(stationId: String) {
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                guard let stationDetailVC = vc as? DCStationDetailViewController,
                    let vcStationId = stationDetailVC.selectStationInfo?.stationId else {
                    continue
                }
                if vcStationId == stationId {
                    stationDetailVC.prelaodDataFromServer()
                    navigationController?.popToViewController(stationDetailVC, animated: true)
                    return
                }
            }
        }
        
        let stationDetailVC = DCStationDetailViewController.storyboardInstantiate()
        let station = DCStation()
        station.stationId = stationId
        stationDetailVC.selectStationInfo = station
        navigationController?.pushViewController(stationDetailVC!, animated: true)
    }
    
    func clickedImage(imageView: UIImageView, index: Int) {
        dismissKeyboard(true)
        var images = [KZImage]()
        for imagePath in article.images as! [String] {
            let image = KZImage(URL: NSURL(imagePath: imagePath))
            images.append(image)
        }
        
        let imageViewer = KZImageViewer()
        imageViewer.showImages(images, selectImageView: imageView, atIndex: index)
    }
}

extension CircleArticleViewController {
    func reloadTableView() {
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 1
        if article.likes.count > 0 {
            rowCount += 1
        }
        rowCount += article.comments.count
        return rowCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // content
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ArticleContentCell", forIndexPath: indexPath) as! ArticleContentCell
            cell.setupWithArticle(article)
            cell.delegate = self
            return cell
        }
        
        // like
        if (article.likes.count > 0) && (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("ArticleLikeBarCell", forIndexPath: indexPath) as! ArticleLikeBarCell
            cell.setupWithArticle(article)
            cell.likeBar.userInteractionEnabled = false
            return cell
        }
        
        // comment
        var commentIndex = indexPath.row - 1
        if article.likes.count > 0 {
            commentIndex -= 1
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCommentCell", forIndexPath: indexPath) as! ArticleCommentCell
        cell.setupWithComment(article.comments[commentIndex] as! DCArticleComment)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            
        }
            
        else if (article.likes.count > 0) && (indexPath.row == 1) {
            performSegueWithIdentifier(pushToLikeListSegueId, sender: article)
        }
        
        else {
            var commentIndex = indexPath.row - 1
            if article.likes.count > 0 {
                commentIndex -= 1
            }
            let comment = article.comments[commentIndex] as! DCArticleComment
            replyComment(comment)
        }
    }
}


// MARK: - NSNotification
extension CircleArticleViewController {
    func userDidChange(notification: NSNotification) {
        reloadTableView()
    }
}
