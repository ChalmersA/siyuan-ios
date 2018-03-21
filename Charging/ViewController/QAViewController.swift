//
//  QAViewController.swift
//  Charging
//
//  Created by Blade on 15/8/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

class QAViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var questionIndex: NSIndexPath?
    var faqCell: FaqCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        faqCell = tableView.dequeueReusableCellWithIdentifier("QuestionAnswerCell") as? FaqCell
        tableView.rowHeight = UITableViewAutomaticDimension

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let index = questionIndex {
            dispatch_after(0, dispatch_get_main_queue()) {
                self.scrollToIndex(index);
            }
        }
    }
    
    func scrollToIndex(index:NSIndexPath) {
        tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    @IBAction func navigationBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - UITableView
    
//    let questions = ["1. 如何使用华商三优电桩充电？", "2. 为什么我的充电会失败？", "3. 如何找到充电桩？", "4. 如何预约成功？", "5. 如何支付电费？"]
//    let answers = ["您好，如果您是桩主，直接登陆上优易充，然后在【充电】按钮界面中连接自己电桩的蓝牙信号，即可充电，如果您是普通用户，需要进行预约才能进行充电。",
//        "您好，充电失败会有以下问题：1.充电桩和车接触不良。2.您登陆的不是桩主、家人、对电桩进行预约的账号都将无法连接充电桩。3. 您连接的充电桩蓝牙信号不对。4. 您车子的电量是饱满状态。5.车子没有灭火。6. 预约的充电桩和连接的充电桩不一致。7. 充电枪连接反了。8. 您预约的时间没到。9. 您过了您的预约时间。",
//        "您好，如果您对于电桩是桩主，可以通过【我】--【电桩管理】--【电桩设置】--【电桩信息】里查询到电桩的地址；如果您对于电桩是普通用户，可以通过【寻找电桩】里的搜索栏填写相应的关键字来寻找电桩，也可以点击右上角的地图标点来进行地图查找。",
//        "找到你想预约的桩，如果显示没发布，则无法进行预约，显示已发布，就可以在发布时间内设置所需要的充电时间，点击下面的预约按钮，订单就发给了其电桩的主人，然后等待桩主的回复，如果订单显示已拒绝，则您申请的充电订单失败，如果显示进行导航，则可以预约成功。",
//        "支付电费是属于普通用户向桩主进行付款的一项功能，当租户充电完成后，在预约订单中会显示去付款按钮，点击其按钮会显示支付方式，继续点击会显示租户的充电情况（充电费用、充电时间、充电电量等等）、收款人，然后点击立即支付，就会按照通常支付环境进行支付。"]
    
    let questions = ["1. 为什么我收不到验证手机号码的短信？","2. App上显示的充电价格是什么费用？","3. 在哪里可以快速找到充电桩群？","4. 为什么我不能同时预约两个充电枪口？","5. 我是否只能通过预约充电枪口才能连接充电桩的充电枪口启动充电？","6. 为什么我充电完成后订单状态没有改变？"]
    let answers = ["网络通讯出现异常情况可能会造成丢失或延时收到，需要您耐心等待，如果您始终无法收到，您可以致电客服咨询。",
        "App上显示的充电单价是由“电费+服务费”组成，也是充电电量结算单价，价格设置权归该充电桩群的运营商所有。如在预约过程中遇到价格变化，以预约订单中的充电单价为结算依据。",
        "您可以通过“寻找电桩”的“地图/列表”页面上通过筛选来寻找您要的充电桩群，点击按钮“导航”即可跳转导航应用来为您导航路线。",
        "目前一个用户在24小时内只能提交3个预约订单，若想新增/重新预约，需把前一订单取消或完成充电进行支付后才能预约。",
        "您也可以通过易卫充APP现场扫描充电桩的电枪口二维码，若当前时段内该电枪口未被其他用户预约或者占用，此时您可以连接该充电枪口启动充电。",
        "存在因网络情况不佳导致不能及时上传记录至云端的情况，此时充电完成后订单状态会停留在“充电中”，需静待电桩上报记录至云端后，订单状态会自行改变，如您有疑问可致电客服热线咨询或自行与运营商沟通。"]

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("QuestionAnswerCell") as? FaqCell {
            cell.questionLabel.text = questions[indexPath.row]
            cell.answerLabel.text = answers[indexPath.row]
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cell = faqCell {
            cell.questionLabel.text = questions[indexPath.row]
            cell.answerLabel.text = answers[indexPath.row]
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.bounds = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: cell.bounds.height)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            let height = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            return (height + 1.0)
        }
        return 0
    }
    
}
