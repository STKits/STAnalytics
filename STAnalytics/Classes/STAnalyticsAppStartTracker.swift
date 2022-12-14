//
//  STAnalyticsAppStartTracker.swift
//  StonkIOS
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/1
//

import Foundation

// auto 启动采集
public class STAnalyticsAppStartTracker:NSObject {
    // 被动启动
    public var isPassively:Bool = false
    // 热启动
    private var isRelaunch:Bool = false
    
    var eventId:String {
        return self.isPassively ? STAnalyticsEventName.kAppStartPassively : STAnalyticsEventName.kAppStart
    }
    
    public override init() {
        super.init()
    }
    
    /// 可添加启动额外参数，如deepLink等启动字段
    public func autoTrackEvent(with properties:[String:Any] = [:]) {
        var eventProperties = [String:Any]()
        if self.isPassively {
            eventProperties[STAnalyticsParameterNames.kResumeFromBackground] = false
        } else {
            eventProperties[STAnalyticsParameterNames.kResumeFromBackground] = self.isRelaunch
        }
        eventProperties[STAnalyticsParameterNames.kAutoTrack] = true
        eventProperties.merge(properties) { (_, new) in new }
        STAnalytics.shared.track(eventId, properties: eventProperties)
        // 冷启动 -> 热启动
        self.isRelaunch = true
    }
}
