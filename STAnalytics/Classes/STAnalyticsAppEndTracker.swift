//
//  STAnalyticsAppEndTracker.swift
//  StonkIOS
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/1
//

import Foundation

// auto 退出采集
public class STAnalyticsAppEndTracker:NSObject {
    
    var eventId:String {
        return STAnalyticsEventName.kAppEnd
    }
    // 通过此id获取时长
    private var timerEventId:String?
    
    public override init() {
        super.init()
    }
    
    public func autoTrackEvent() {
        var eventProperties = [String:Any]()
        eventProperties[STAnalyticsParameterNames.kAutoTrack] = true
        STAnalytics.shared.trackTimerEnd(event: eventId)
    }
    
    public func trackTimerStart() {
        self.timerEventId = STAnalytics.shared.trackTimerStart(event: eventId)
    }
}
