//
//  PoleEvaluationsViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/10/9.
//  Copyright © 2015年 xpg. All rights reserved.
//

import UIKit

class PoleEvaluationsViewController: CircleViewController {

    var station: DCStation!
    var scoresHeader: PoleEvaluationHeader?
    
    override var articleDeleteMessage: String {
        return "是否删除该条评价"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "所有评价"
        let header = PoleEvaluationHeader.ibInstance()
        header.nameLabel.text = station.stationName
        header.totalScoreLabel.text = String(format: "%.1f分", station.commentAvgScore)
        header.starsView.setScore(Float(station.commentAvgScore))
        tableView.tableHeaderView = header
        scoresHeader = header
        
        fetchPoleScores()
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
        guard let stationId = station.stationId else {
            showHUDText("电桩不存在")
            return
        }
        
        let hud = showHUDIndicator()
        CircleAPI.getArticleList(pageIndex, pageSize: 10, type: .AllEvaluate, userId: DCApp.sharedApp().user?.userId, stationId: stationId) { (success, articles, errorMessage) in
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
                
                self.fetchPoleScores()
                
                self.reloadTableView()
                hud.hide(true)
            } else {
                self.hideHUD(hud, withText: errorMessage)
            }
        }
    }
    
    func fetchPoleScores() {
        guard let stationId = station.stationId else {
            return
        }
        
        CircleAPI.getPileScores(stationId) { [weak weakSelf = self] (success, scores, errorMessage) -> Void in
            guard let strongSelf = weakSelf else {
                return
            }
            if let scores = scores {
                strongSelf.scoresHeader?.environmentScoreLabel.text = String(format: "%.1f", scores.envirAvgScore)
                strongSelf.scoresHeader?.deviceScoreLabel.text = String(format: "%.1f", scores.devAvgScore)
                strongSelf.scoresHeader?.speedScoreLabel.text = String(format: "%.1f", scores.cspeedAvgScore)
                strongSelf.scoresHeader?.totalScoreLabel.text = String(format: "%.1f", scores.commentAvgScore)
                strongSelf.scoresHeader?.starsView.setScore(Float(scores.commentAvgScore))
            }
        }
    }
}

// MARK: - Storyboard
extension PoleEvaluationsViewController {
    override class func storyboardInstantiate() -> PoleEvaluationsViewController {
        return UIStoryboard(name: "Attention", bundle: nil).instantiateViewControllerWithIdentifier("PoleEvaluationsViewController") as! PoleEvaluationsViewController
    }
}


// MARK: - UITableView
extension PoleEvaluationsViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CircleCell", forIndexPath: indexPath) as! CircleCell
        let article = articles[indexPath.row]
        cell.setupWithArticle(article)
        cell.setupEvaluation(article, withPrefix: false)
        cell.delegate = self
        return cell
    }
}
