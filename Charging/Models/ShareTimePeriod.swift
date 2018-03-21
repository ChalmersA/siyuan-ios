//
//  ShareTimePeriod.swift
//  Charging
//
//  Created by xpg on 7/3/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

struct TimePeriod {
    let startTimePoint: Int
    let endTimePoint: Int
    
    init?(startTimePoint: Int, endTimePoint: Int) {
        self.startTimePoint = startTimePoint
        self.endTimePoint = endTimePoint
        if startTimePoint >= endTimePoint {
            return nil
        }
    }
    
    func isOverlapWithPeriod(period: TimePeriod) -> Bool {
        if period.startTimePoint >= endTimePoint {
            return false
        }
        if period.endTimePoint <= startTimePoint {
            return false
        }
        return true
    }
}

struct ShareTimePeriods {
    var periods: [TimePeriod] = []
    
    init(shareTime: DCTime) {
        let shareStartTime = shareTime.startTime
        let shareEndTime = shareTime.endTime
        
        let weekdays = shareTime.weekString.componentsSeparatedByString(",").map {
            Int($0)
        }
        for weekday in weekdays {
            if let weekday = weekday {
                if (weekday >= 1) && (weekday <= 7) {
                    var startTime = shareStartTime
                    startTime.hour += 24 * (weekday - 1)
                    var endTime = shareEndTime
                    endTime.hour += 24 * (weekday - 1)
                    
                    if let period = TimePeriod(startTimePoint: minutesFromClockTime(startTime), endTimePoint: minutesFromClockTime(endTime)) {
                        periods.append(period)
                    }
                }
            }
        }
    }
    
    func isConflictedWithTimePeriods(timePeriods: ShareTimePeriods) -> Bool {
        for period in timePeriods.periods {
            for shareTimePeriod in periods {
                if period.isOverlapWithPeriod(shareTimePeriod) {
                    return true
                }
            }
        }
        return false
    }
}

extension ShareTimePeriods: CustomStringConvertible {
    var description: String {
        var text = ""
        for period in periods {
            text += "(\(period.startTimePoint) ~ \(period.endTimePoint)) "
        }
        return text
    }
}

extension DCTime {
    func conflictWithShareTimes(shareTimes: [DCTime]) -> [DCTime] {
        let candidatePeriods = ShareTimePeriods(shareTime: self)
        var conflictTimes: [DCTime] = []
        for shareTime in shareTimes {
            let shareTimePeriods = ShareTimePeriods(shareTime: shareTime)
            if candidatePeriods.isConflictedWithTimePeriods(shareTimePeriods) {
                conflictTimes.append(shareTime)
            }
        }
        return conflictTimes
    }
    
    class func detectShareTimesConflict(shareTimes: [DCTime]) -> [String: [DCTime]] {
        var conflictDict: [String: [DCTime]] = [:]
        if shareTimes.count > 1 {
            for i in 1..<shareTimes.count {
                let time = shareTimes[i]
                let compareTimes = Array(shareTimes[0..<i])
                let conflictTimes = time.conflictWithShareTimes(compareTimes)
                if conflictTimes.isEmpty {
                    conflictDict.removeValueForKey(time.timeId)
                } else {
                    conflictDict.updateValue(conflictTimes, forKey: time.timeId)
                }
            }
        }
        return conflictDict
    }
}
