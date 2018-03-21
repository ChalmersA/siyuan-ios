//
//  ScrollBar.swift
//  Charging
//
//  Created by xpg on 8/17/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class ScrollBar: UIScrollView {

    // MARK: Properties
    var buttons: [UIButton] = []
    var displayButtonCount: CGFloat = 1
    var indicator: UIView!
    var indicatorHeight: CGFloat = 2 {
        didSet {
            updateIndicator()
        }
    }
    var indicatorBottomSpace: CGFloat = 2 {
        didSet {
            updateIndicator()
        }
    }
    var selectedIndex: Int?
    var didClickedButtonHandler: ((buttonIndex: Int) -> Void)?
    
    // MARK: - UIView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func intrinsicContentSize() -> CGSize {
        var width: CGFloat = 0
        for button in buttons {
             width += button.intrinsicContentSize().width
        }
        return CGSize(width: width, height: 44)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth = bounds.width / displayButtonCount
        contentSize = CGSize(width: buttonWidth * CGFloat(buttons.count), height: 1)
        for (index, button) in buttons.enumerate() {
            button.frame = CGRect(x: buttonWidth * CGFloat(index), y: 0, width: buttonWidth, height: bounds.height)
        }
        updateIndicator()
    }
    
    // MARK: - ScrollBar
    func selectIndex(index: Int) {
        selectedIndex = index
        
        for (index, button) in buttons.enumerate() {
            button.selected = (index == selectedIndex)
        }
        
        updateIndicator()
        
        let buttonWidth = bounds.width / displayButtonCount
        var buttonFrame = CGRect(x: buttonWidth * CGFloat(index), y: 0, width: buttonWidth, height: bounds.height)
        buttonFrame.insetInPlace(dx: -buttonFrame.width * 0.5, dy: 0)
        scrollRectToVisible(buttonFrame, animated: true)
    }
    
    func setup() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        scrollEnabled = false
        
        indicator = UIView(frame: CGRectZero)
        indicator.backgroundColor = UIColor.whiteColor()
        addSubview(indicator)
    }
    
    func updateIndicator() {
        if let selectedIndex = selectedIndex {
            indicator.hidden = false
            
            let buttonWidth = bounds.width / displayButtonCount
            indicator.frame = CGRect(x: 0, y: bounds.maxY - indicatorHeight - indicatorBottomSpace, width: buttonWidth * 0.75, height: indicatorHeight)
            indicator.center.x = buttonWidth * (CGFloat(selectedIndex) + 0.5)
        } else {
            indicator.hidden = true
        }
    }
    
    func setButtons(tabButtons: [UIButton], displayCount: CGFloat) {
        for button in buttons {
            button.removeFromSuperview()
        }
        selectedIndex = nil
        
        for button in tabButtons {
            button.addTarget(self, action: #selector(ScrollBar.clickedButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addSubview(button)
            buttons.append(button)
        }
        
        displayButtonCount = displayCount
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Aciton
    func clickedButton(button: UIButton) {
        if let index = buttons.indexOf(button) {
            selectIndex(index)
            
            if let handler = didClickedButtonHandler {
                handler(buttonIndex: index)
            }
        }
    }
    
}
