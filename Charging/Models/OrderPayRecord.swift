//
//  OrderPayRecord.swift
//  Charging
//
//  Created by xpg on 7/27/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class OrderPayRecord: NSObject {
    
    // MARK: Properties
    let payTime: NSDate
    let payFee: Float
    
    // MARK: Initialization
    init(payTime: NSDate, payFee: Float) {
        self.payTime = payTime
        self.payFee = payFee
    }
    
    // MARK: - NSObject
    override func isEqual(object: AnyObject?) -> Bool {
        if let record = object as? OrderPayRecord {
            return payTime.isEqualToDate(record.payTime)
        }
        return false
    }
    
    override var hash: Int {
        return payTime.hash
    }
    
}
