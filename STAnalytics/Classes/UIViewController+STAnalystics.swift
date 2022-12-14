//
//  UIViewController+STAnalystics.swift
//  StonkIOS
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/1
//

import UIKit

extension UIViewController {
    
    static let swizzleViewDidAppear: () = {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.stAnalyticsViewDidAppear(_:))
        STAnalyticsRuntime.exchangeMethod(targetSelector: originalSelector,
                                             replaceSelector: swizzledSelector,
                                             targetClass: UIViewController.self)
    }()
    
    @objc private func stAnalyticsViewDidAppear(_ animated: Bool) {
        self.stAnalyticsViewDidAppear(animated)
        if self.shouldTrackAppViewScreen() {
            var properties = [String:Any]()
            properties[STAnalyticsParameterNames.kScreenName] = String(describing: self.classForCoder)
            STAnalytics.shared.track(STAnalyticsEventName.kScreenView, properties: properties)
        }
    }
    
    // 是否为黑名单中的类或子类
    private func shouldTrackAppViewScreen() -> Bool {
        for cls in STAnalytics.shared.blackViewControllerList {
            if self.isKind(of: cls) {
                return false
            }
        }
        //        print("====shouldTrackAppViewScreen \(self)")
        return true
    }
    
}
