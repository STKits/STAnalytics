//
//  STAnalyticsTrackTimer.swift
//  StonkIOS
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/2
//

import Foundation

private struct STAnalyticTrackTimerModel {
    var eventBegin:Int
    var eventIsPause:Bool
    var eventLastDuration:Int
}

// 分auto 和 custom（eg：video）
public class STAnalyticsTrackTimer: NSObject {
    // 系统启动时间（ms）
    public static var systemUpTime: Int {
        return Int(ProcessInfo.processInfo.systemUptime * 1000)
    }
    
    private var eventIds    = [String:[String:Any]]()
    
    public override init() {
        super.init()
    }
    
    public func generateEventId(by eventName:String) -> String {
        guard !eventName.isEmpty && !eventName.hasSuffix(STAnalyticsKey.eventIdSuffix) else {
            return eventName
        }
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let eventId = "\(eventName)_\(uuid)_\(STAnalyticsKey.eventIdSuffix)"
        return eventId
    }
    
    public func eventName(from eventId:String) -> String {
        guard eventId.hasSuffix(STAnalyticsKey.eventIdSuffix) else {
            return eventId
        }
        let eventName = eventId.components(separatedBy: "_").first ?? eventId
        return eventName
    }
    
    // 开始记录
    public func trackTimerStart(eventId:String) {
        let params:[String:Any] = [STAnalyticsKey.eventBegin: STAnalyticsTrackTimer.systemUpTime,
                                   STAnalyticsKey.eventLastDuration : 0,
                                   STAnalyticsKey.eventIsPause : false]
        self.eventIds[eventId] = params
    }
    
    // 暂停记录(前提状态：开始), 这边外部可能传的不是id
    public func trackTimerPause(eventId:String) {
        // 未开始
        guard var eventTimer = self.eventIds[eventId] else {
            return
        }
        // 暂停，再暂停
        if let isPause = eventTimer[STAnalyticsKey.eventIsPause] as? Bool, isPause {
            return
        }
        
        let systemUpTime = STAnalyticsTrackTimer.systemUpTime
        let eventBegin = eventTimer[STAnalyticsKey.eventBegin] as? Int ?? 0
        var eventDuration = systemUpTime - eventBegin
        // 计算暂停前统计的时长
        let lastDuration = eventTimer[STAnalyticsKey.eventLastDuration] as? Int ?? 0
        if eventDuration > 0 {
            eventDuration += lastDuration
        }
        
        eventTimer[STAnalyticsKey.eventBegin]        = systemUpTime
        eventTimer[STAnalyticsKey.eventLastDuration] = eventDuration
        eventTimer[STAnalyticsKey.eventIsPause]      = true
        self.eventIds[eventId] = eventTimer
    }
    
//    private func handleEventPause(eventId:String) -> {
//
//    }
    
    // 恢复记录(前提状态：暂停)
    public func trackTimerResume(eventId:String) {
        // 未开始
        guard var eventTimer = self.eventIds[eventId] else {
            return
        }
        // 未暂停
        guard let isPause = eventTimer[STAnalyticsKey.eventIsPause] as? Bool, isPause else {
            return
        }
        let systemUpTime = STAnalyticsTrackTimer.systemUpTime
        
        eventTimer[STAnalyticsKey.eventBegin]   = systemUpTime
        eventTimer[STAnalyticsKey.eventIsPause] = false
        self.eventIds[eventId] = eventTimer
    }
    
    // 结束记录
    public func trackTimerEnd(eventId:String, properties:[String:Any] = [:]) {
        guard let eventTimer = self.eventIds[eventId],
              let beginTime = eventTimer[STAnalyticsKey.eventBegin] as? Int else {
            STAnalytics.shared.track(eventId, properties: properties)
            return
        }
        var prop = properties
        self.eventIds.removeValue(forKey: eventId)
        
        let lastDuration = eventTimer[STAnalyticsKey.eventLastDuration] as? Int ?? 0
        let isPause = eventTimer[STAnalyticsKey.eventIsPause] as? Bool ?? false
        
        var eventDuration:Int = 0
        
        if !isPause {
            let currentTime = STAnalyticsTrackTimer.systemUpTime
            eventDuration = currentTime - beginTime
        } else {
            
        }
        
        if lastDuration > 0 {
            eventDuration += lastDuration
        }
        
        prop[STAnalyticsParameterNames.kEventDuration] = eventDuration
        
        STAnalytics.shared.track(eventId, properties: prop)
    }
    
    public func pauseAllEventTimers() {
        self.eventIds.forEach { (key, value) in
            // 不包括后台事件
            if self.eventName(from: key) == STAnalyticsEventName.kAppEnd {
                return
            }
            var eventTimer = value
            let isPause = eventTimer[STAnalyticsKey.eventIsPause] as? Bool ?? false
            if !isPause { // 开始/恢复
                let systemUpTime = STAnalyticsTrackTimer.systemUpTime
                let eventBegin = eventTimer[STAnalyticsKey.eventBegin] as? Int ?? 0
                var eventDuration = systemUpTime - eventBegin
                // 计算暂停前统计的时长
                let lastDuration = eventTimer[STAnalyticsKey.eventLastDuration] as? Int ?? 0
                if eventDuration > 0 {
                    eventDuration += lastDuration
                }
                
                eventTimer[STAnalyticsKey.eventBegin]        = systemUpTime
                eventTimer[STAnalyticsKey.eventLastDuration] = eventDuration
                self.eventIds[key] = eventTimer
            }
        }
    }
    
    public func resumeAllEventTimers() {
        self.eventIds.forEach { (key, value) in
            var eventTimer = value
            let systemUpTime = STAnalyticsTrackTimer.systemUpTime
            eventTimer[STAnalyticsKey.eventBegin] = systemUpTime
            self.eventIds[key] = eventTimer
        }
    }
    
    // MARK: - Private methods
    
}
