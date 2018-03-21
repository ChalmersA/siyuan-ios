//
//  PoleFilterView.swift
//  Charging
//
//  Created by xpg on 8/13/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class FileterView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observerNotifications()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        observerNotifications()
    }
    
    func observerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FileterView.notified(_:)), name:NOTIFICATION_USER_LOGINVIEW_WILL_SHOW, object: nil);
    }
    
    func notified(notify:NSNotification) {
        if(notify.name == NOTIFICATION_USER_LOGINVIEW_WILL_SHOW) {
            loginViewShow()
        }
    }
    
    func deSetup() {
        // Overrride this/
    }
    
    func loginViewShow() {
        // Overrride this
        NSLog("Notified %@", self);
    }
}

class PoleFilterView: FileterView {
    
    static let animate_time_show:Double = 0.5
    static let animate_time_hide:Double = 0.3

    var backgroundView: UIControl!
    var contentView: PoleFilterContentView!
    var closeButton: UIButton!
    var originPoint: CGPoint?
    
    var dismissedHandler: ((poleType: DCSearchStationType, bookableOnly: Bool) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        if let point = originPoint {
            closeButton.center = point
        }
    }
    
    private func setup() {
        backgroundView = UIControl(frame: bounds)
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0
        addSubview(backgroundView)
        
        contentView = PoleFilterContentView.loadViewWithNib("PoleFilterContentView")
        contentView.setCornerRadius(4)
        addSubview(contentView)
        
//        containerView = UIView(frame: contentView.frame)
//        containerView.backgroundColor = UIColor.clearColor()
//        containerView.layer.shadowColor = UIColor.darkGrayColor().CGColor
//        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
//        containerView.layer.shadowOpacity = 1
//        containerView.layer.shadowRadius = 4
//        addSubview(containerView)
//        containerView.addSubview(contentView)
        
        closeButton = UIButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 44, height: 44)))
        closeButton.setImage(UIImage(named: "map_filter_close"), forState: UIControlState.Normal)
        
        let hideSelector:Selector = #selector(PoleFilterView.hide)
        if self.respondsToSelector(hideSelector) {
            backgroundView.addTarget(self, action: hideSelector, forControlEvents: UIControlEvents.TouchUpInside)
            closeButton.addTarget(self, action: hideSelector, forControlEvents: UIControlEvents.TouchUpInside)
        }
        addSubview(closeButton)
    }
    
    func show(fromPoint point: CGPoint, toRect: CGRect) {
        originPoint = point
        closeButton.center = point
        let window = DCApp.appDelegate().window
        frame = window.bounds
        window.addSubview(self)
        
        backgroundView.alpha = 0
        
        let animationView = contentView
        animationView.frame = toRect
        animationView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        animationView.center = point
        let toPoint = CGPoint(x: toRect.midX, y: toRect.midY)
        UIView.animateWithDuration(PoleFilterView.animate_time_show, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backgroundView.alpha = 0.5
                animationView.transform = CGAffineTransformIdentity
                animationView.center = toPoint
            }, completion: { (finished) -> Void in
                
        })
    }
    
    func hide() {
        hideWithDuration();
    }
    
    func hideWithDuration(duration:Double = PoleFilterView.animate_time_hide) {
        let animationView = contentView
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.backgroundView.alpha = 0
            if let point = self.originPoint {
                animationView.center = point
            }
            animationView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            
            }, completion: { (finished) -> Void in
                if let handler = self.dismissedHandler {
                    handler(poleType: self.contentView.poleType, bookableOnly: self.contentView.bookableOnly)
                }
                self.removeFromSuperview()
        })
    }
    
    override func loginViewShow() {
        super.loginViewShow();
        hideWithDuration(0)
    }
    
    override func deSetup() {
        super.deSetup()
        // Overrride this/
        let hideSelector:Selector = #selector(PoleFilterView.hide)
        if self.respondsToSelector(hideSelector) {
            backgroundView.removeTarget(self, action: hideSelector, forControlEvents: UIControlEvents.TouchUpInside)
            closeButton.removeTarget(self, action: hideSelector, forControlEvents: UIControlEvents.TouchUpInside)
        }
    }

}


class PoleFilterListView: FileterView {
    static let animate_time_show:Double = 0.5
    static let animate_time_hide:Double = 0.3
    
    var backgroundView: UIControl!
    var containerView: UIView!
    var contentView: PoleFilterContentView!
    var contentTop: CGFloat = 0
    
    var willDismissHandler: ((poleType: DCSearchStationType, bookableOnly: Bool) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        containerView.frame = CGRect(x: 0, y: contentTop, width: bounds.width, height: contentView.frame.height)
    }
    
    private func setup() {
        backgroundView = UIControl(frame: bounds)
        backgroundView.backgroundColor = UIColor.clearColor()
        let hideSelector:Selector = #selector(PoleFilterView.hide)
        if self.respondsToSelector(hideSelector) {
            backgroundView.addTarget(self, action: hideSelector, forControlEvents: UIControlEvents.TouchDown)
        }
        addSubview(backgroundView)
        
        contentView = PoleFilterContentView.loadViewWithNib("PoleFilterContentView")
        
        containerView = UIView(frame: bounds)
        containerView.clipsToBounds = true
        containerView.addSubview(contentView)
        addSubview(containerView)
    }
    
    func show(fromTop top: CGFloat) {
        contentTop = top

        let window = DCApp.appDelegate().window
        frame = window.bounds
        let contentHeight = contentView.frame.height;
        containerView.frame = CGRect(x: 0, y: contentTop, width: bounds.width, height: contentHeight)
        contentView.frame = CGRect(x: 0, y: -contentHeight, width: containerView.bounds.width, height: contentHeight)
        window.addSubview(self)
        
        UIView.animateWithDuration(PoleFilterListView.animate_time_show, animations: { () -> Void in
                self.contentView.frame.origin.y = 0
            }, completion: { (finished) -> Void in
                
        })
    }
    
    func hide() {
        hideWithDuration();
    }
    
    func hideWithDuration(duration:Double = PoleFilterListView.animate_time_hide) {
        if let handler = self.willDismissHandler {
            handler(poleType: self.contentView.poleType, bookableOnly: self.contentView.bookableOnly)
        }
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.contentView.frame.origin.y = -self.contentView.frame.height;
            }, completion: { (finished) -> Void in
                self.removeFromSuperview()
        })
        deSetup()
    }
    
    override func loginViewShow() {
        super.loginViewShow();
        hideWithDuration(0)
    }
    
    override func deSetup() {
        super.deSetup()
        // Overrride this/
        let hideSelector:Selector = #selector(PoleFilterView.hide)
        if self.respondsToSelector(hideSelector) {
            backgroundView.removeTarget(self, action: hideSelector, forControlEvents: UIControlEvents.TouchDown)
        }
    }
    
}

class PoleFilterContentView: UIView {
    
    @IBOutlet weak var allControl: UIControl!
    @IBOutlet weak var privatePoleControl: UIControl!
    @IBOutlet weak var stationControl: UIControl!
    @IBOutlet weak var bookableOnlySwitch: UISwitch!
    var filterChanged: ((poleType: DCSearchStationType, bookableOnly: Bool) -> Void)?
    
    var poleTypeControls: [UIControl] {
        return [allControl, privatePoleControl, stationControl]
    }
    
    var poleType: DCSearchStationType {
        get {
            if privatePoleControl.selected {
                return .Public
            } else if stationControl.selected {
                return .Special
            }
            return .All
        }
        set {
            for control in poleTypeControls {
                updateControl(control, selected:false)
            }
            
            switch (newValue) {
            case .All: updateControl(allControl, selected:true)
            case .Public: updateControl(privatePoleControl, selected:true)
            case .Special: updateControl(stationControl, selected:true)
            }
        }
    }
    
    var bookableOnly: Bool {
        get {
            return bookableOnlySwitch.on
        }
        set {
            bookableOnlySwitch.on = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for control in poleTypeControls {
            updateControl(control, selected:false)
        }
        bookableOnlySwitch.onTintColor = UIColor.paletteDCMainColor()
    }
    
    func updateControl(control: UIControl, selected: Bool) {
        control.selected = selected
        for subview in control.subviews {
            if let image = subview as? UIImageView {
                image.highlighted = selected
            }
            if let label = subview as? UILabel {
                label.highlighted = selected
            }
        }
    }
    
    @IBAction func clickedType(sender: UIControl) {
        var clickedPoleType: DCSearchStationType = .All
        if sender == privatePoleControl {
            clickedPoleType = .Public
        } else if sender == stationControl {
            clickedPoleType = .Special
        }
        
        if poleType != clickedPoleType {
            poleType = clickedPoleType
            if let filterChanged = filterChanged {
                filterChanged(poleType: poleType, bookableOnly: bookableOnly)
            }
        }
    }
    
    @IBAction func bookableOnlyChanged(sender: AnyObject) {
        if let filterChanged = filterChanged {
            filterChanged(poleType: poleType, bookableOnly: bookableOnly)
        }
    }
}
