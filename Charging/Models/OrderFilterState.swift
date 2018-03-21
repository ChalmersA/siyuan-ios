//
//  OrderFilterState.swift
//  Charging
//
//  Created by xpg on 8/10/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import Foundation

@objc enum OrderFilterState: Int {
    case All
    case Last3Days
    case Last14Days
    case Last30Days
    case Last90Days
}

extension OrderFilterState {
    var startOffset: NSString? {
        
        switch self {
        case All: return nil
        case Last3Days: return dateWithDay(2)
        case Last14Days: return dateWithDay(13)
        case Last30Days: return dateWithDay(29)
        case Last90Days: return dateWithDay(89)
        }
    }
    var endOffset: NSString? {
        switch self {
        case All: return nil
        default: return NSDateFormatter.pileEvaluateDateFormatter().stringFromDate(NSDate())
        }
    }
}

extension DCOrder {
    static func orderFilterStartOffset(state: OrderFilterState) -> NSString? {
        return state.startOffset
    }
    
    static func orderFilterEndOffset(state: OrderFilterState) -> NSString? {
        return state.endOffset
    }
}

func dateWithDay(days: Double) -> NSString {
    let oneDay: NSTimeInterval = 24 * 60 * 60 * 1
    var theDate: NSDate
    var string: NSString
    
    theDate = NSDate(timeIntervalSinceNow: -oneDay * days)
    string = NSDateFormatter.pileEvaluateDateFormatter().stringFromDate(theDate)
    return string
}