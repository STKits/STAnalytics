//
//  STAnalyticsConstants.swift
//  StonkIOS
//
//  Author: yyb 
//  Email:  cnjsyyb@163.com
//  Date:   2022/12/1
//

import Foundation

// 通知名
struct STkAnalyticsNotificationName {
    static let kAppLifecycleStateWillChange = Notification.Name("STAnalytics.kAppLifecycleStateWillChange")
    static let kAppLifecycleStateDidChange = Notification.Name("STAnalytics.kAppLifecycleStateDidChange")
}

// key
struct STAnalyticsKey {
    static let appLifecycleNew = "new"
    static let appLifecycleOld = "old"
    
    static let eventBegin           = "event_begin"
    static let eventIsPause         = "is_pause"
    static let eventLastDuration    = "event_last_duration"
    
    static let eventIdSuffix        =  "_timer"
}

/* 避免和firebase预留字段重复
 https://support.google.com/firebase/answer/9234069?authuser=0&visit_id=638055943815900049-170418641&rd=1
ad_activeview, ad_click, ad_exposure, ad_query, ad_reward, adunit_exposure,
app_background, app_clear_data, app_exception, app_remove,
app_store_refund, app_store_subscription_cancel, app_store_subscription_convert, app_store_subscription_renew,
app_update, app_upgrade, dynamic_link_app_open, dynamic_link_app_update, dynamic_link_first_open,
error, firebase_campaign, first_open, first_visit, in_app_purchase,
notification_dismiss, notification_foreground, notification_open, notification_receive,
os_update, session_start, session_start_with_rollout, user_engagement
 */
public struct STAnalyticsEventName {
    // 冷/热启动
    public static let kAppStart            = "stonk_app_start"
    // 被动启动
    public static let kAppStartPassively   = "stonk_app_start_passively"
    // 退出
    public static let kAppEnd              = "stonk_app_end"
    // 分享
    public static let kShare               = "stonk_share" // AnalyticsEventShare
    // 观看视频
    public static let kWatchVideo          = "stonk_video_watch"
    // 屏幕视图跟踪
    public static let kScreenView          = "stonk_screen_view"; // AnalyticsEventScreenView
}

/// 参数名
public struct STAnalyticsParameterNames {
    public static let kResumeFromBackground  = "resume_from_background"
    public static let kEventDuration         = "event_duration"
    public static let kAutoTrack             = "auto_track"
    public static let kScreenName            = "screen_name"
    public static let kShareType             = "share_type"
    public static let kShareContent          = "share_content"
}

// App
