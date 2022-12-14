//
//  STAnalyticsAppLifecycle.swift
//  StonkIOS
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/1
//

import UIKit

enum STAnalyticsAppLifecycleState:Int {
    case initial        = 1
    case start
    case startPassively
    case end
    case terminate
}

class STAnalyticsAppLifecycle: NSObject {
    
    var state:STAnalyticsAppLifecycleState {
        get {
            return _state
        }
        set {
            if _state == newValue {
                return
            }
            let userInfo:[String:Any] = [STAnalyticsKey.appLifecycleNew : newValue,
                                         STAnalyticsKey.appLifecycleOld : _state]
            NotificationCenter.default.post(name: STkAnalyticsNotificationName.kAppLifecycleStateWillChange, object: nil, userInfo: userInfo)
            _state = newValue
            NotificationCenter.default.post(name: STkAnalyticsNotificationName.kAppLifecycleStateDidChange, object: nil, userInfo: userInfo)
        }
    }
    private var _state:STAnalyticsAppLifecycleState = .initial
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        self.registerNotification()
        self.initLaunchedState()
    }
    
    private func registerNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    private func initLaunchedState() {
        DispatchQueue.main.async {
            let isBackground = UIApplication.shared.applicationState == .background
            self.state = isBackground ? .startPassively : .start
        }
    }
    
    @objc
    private func applicationDidBecomeActive(_ notification: Notification) {
        guard let app = self.convertToUIAppliccation(object: notification.object) else {
            return
        }
        guard app.applicationState == .active else { return }
        self.state = .start
    }
    
    @objc
    private func applicationDidEnterBackground(_ notification: Notification) {
        guard let app = self.convertToUIAppliccation(object: notification.object) else {
            return
        }
        guard app.applicationState == .background else { return }
        self.state = .end
    }
    
    @objc
    private func applicationWillTerminate(_ notification: Notification) {
        self.state = .terminate
    }
    
    private func convertToUIAppliccation(object:Any?) -> UIApplication? {
        if let application = object as? UIApplication {
            return application
        }
        return nil
    }
    
}
