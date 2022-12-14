//
//  STAnalyticsRuntime.swift
//  STAnalytics
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/3
//

import Foundation
import ObjectiveC

class STAnalyticsRuntime {
    // MARK: - exchange method

    /// 交换方法
    /// - Parameters:
    ///   - targetSelector: 被交换的方法
    ///   - replaceSelector: 交换的方法
    ///   - targetClass: 目标类
    class func exchangeMethod(targetSelector: Selector,
                              replaceSelector: Selector,
                              targetClass: AnyClass) {
        guard
            let targetMethod    = class_getInstanceMethod(targetClass, targetSelector),
            let replaceMethod   = class_getInstanceMethod(targetClass, replaceSelector) else {
            return
        }
        let didAddMethod  = class_addMethod(targetClass, targetSelector, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod))
        if didAddMethod {
            class_replaceMethod(targetClass, replaceSelector, method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod))
        } else {
            method_exchangeImplementations(targetMethod, replaceMethod)
        }
    }
}
 

