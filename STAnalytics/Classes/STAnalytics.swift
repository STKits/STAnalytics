//
//  STAnalytics.swift
//  StonkIOS
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/1
//

import UIKit

public protocol STAnalyticsDelegate: AnyObject {
    func track(_ eventName: String, properties: [String:Any]?)
}

public class STAnalytics : NSObject {
    
    public static let shared = STAnalytics()
    
    public weak var delegate:STAnalyticsDelegate?
    
    // 黑名单页面，不拦截, 字符串形式
    public var blackViewControllerList = [AnyClass]()
    
    private lazy var appLifecycle       = STAnalyticsAppLifecycle()
    private lazy var appStartTracker    = STAnalyticsAppStartTracker()
    private lazy var appEndTracker      = STAnalyticsAppEndTracker()
    private lazy var trackTimer         = STAnalyticsTrackTimer()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private override init() {
        super.init()
        self.registerNotification()
        self.initTrackTimer()
        self.initAppLifeCycle()
        self.initDefaultBlackViewControllerList()
//        self.swizzleMethods()
    }
    
    public func track(_ eventName: String, properties: [String:Any]?) {
        var event = [String:Any]()
        // 事件名
        event["event"] = eventName
        // 事件发生时间戳（ms, 无法保证每个设备时间的准确性，eg:今天的采集到了未来）
        event["time"]  = Int(Date().timeIntervalSince1970 * 1000)
        // 其他信息（如：用户信息, 设备信息， 应用信息， 运营商，网络等）[这边暂由Firebase记录]
        
        // 具体属性处理
        var eventProperties = [String:Any]()
        if let properties = properties {
            eventProperties.merge(properties) { (_, new) in new }
        }
        // 如果两个时间戳期间用户如果用户进行更改，会导致时间差值出现极大或负数，导致数据作废
        event["properties"] = eventProperties
        self.printEvent(event)
        
        self.delegate?.track(eventName, properties: eventProperties)
    }
    
    /// 开始时长事件记录
    /// - Parameters:
    ///   - event: 事件名
    ///   - cross: 同名事件是否交叉
    /// - Returns: 标识， 默认返回event
    @discardableResult
    public func trackTimerStart(event:String, cross:Bool = false) -> String {
        var eventId = event
        if cross {
            // 通过事件名生成唯一标识
            eventId = self.trackTimer.generateEventId(by: event)
        }
        self.trackTimer.trackTimerStart(eventId: eventId)
        return eventId
    }

    // 后续操作用Start生成的标识
    public func trackTimerPause(event:String) {
        self.trackTimer.trackTimerPause(eventId: event)
    }
    
    public func trackTimerResume(event:String) {
        self.trackTimer.trackTimerResume(eventId: event)
    }
    
    
    /// 结束时长事件记录
    /// - Parameters:
    ///   - event: 事件名，cross为false为name,true, 为事件唯一id
    ///   - cross: 同名事件是否交叉
    public func trackTimerEnd(event:String, properties:[String:Any] = [:], cross:Bool = false) {
        var eventName = event
        if cross {
            eventName = self.trackTimer.eventName(from: event)
        }
        self.trackTimer.trackTimerEnd(eventId: eventName, properties: properties)
    }
    
    private func initTrackTimer() {
        _ = trackTimer
    }
    
    private func initAppLifeCycle() {
        _ = appLifecycle.state
    }
    
    private func initDefaultBlackViewControllerList() {
        if let inputWindowController = NSClassFromString("UIInputWindowController") {
            blackViewControllerList.append(inputWindowController)
        }
        blackViewControllerList.append(UITabBarController.self)
        blackViewControllerList.append(UINavigationController.self)
        blackViewControllerList.append(UIActivityViewController.self)
        if let activityContentViewController = NSClassFromString("UIActivityContentViewController") {
            blackViewControllerList.append(activityContentViewController)
        }
    }
    
    private func swizzleMethods() {
        // 标题可通过协议
        // UIViewController 遵循 AutoTracker 协议
        // getTrackProperties 协议方法中返回自定义的页面信息
        UIViewController.swizzleViewDidAppear
    }
    
    private func registerNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appLifecycleStateDidChange(_:)),
                                       name: STkAnalyticsNotificationName.kAppLifecycleStateDidChange, object: nil)
    }
        
    private func printEvent(_ event: [String:Any]) {
#if DEBUG
        do {
            let prettyData = try JSONSerialization.data(withJSONObject: event, options: .prettyPrinted)
            let json = String(data: prettyData, encoding: .utf8)
            print("[STkAnalytics Event]: \(json ?? "")")
        } catch {
        }
#endif
    }
    
    /// 应用生命周期变化处理
    @objc
    private func appLifecycleStateDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let newState = userInfo[STAnalyticsKey.appLifecycleNew] as? STAnalyticsAppLifecycleState,
              let oldState = userInfo[STAnalyticsKey.appLifecycleOld] as? STAnalyticsAppLifecycleState else { return }
        self.appStartTracker.isPassively = false
        
        // 被动启动
        if oldState == .initial && newState == .startPassively {
            self.appStartTracker.isPassively = true
            self.appStartTracker.autoTrackEvent()
        } else if newState == .start { // 冷（热）启动
            // 恢复trackTimer所有记录
            self.trackTimer.resumeAllEventTimers()
            
            self.appStartTracker.autoTrackEvent()
            // appEndTracker开始计时
           self.appEndTracker.trackTimerStart()
        } else if newState == .end { // 退出
            // 暂停trackTimer所有记录
            self.trackTimer.pauseAllEventTimers()
            
            self.appEndTracker.autoTrackEvent()
            
        }
    }
    
}
