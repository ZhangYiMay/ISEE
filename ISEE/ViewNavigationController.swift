//
//  ViewController.swift
//  ISEE通知助手
//
//  Created by 李博闻 on 16/10/11.
//  Copyright © 2016年 小艺艺. All rights reserved.
//

import UIKit
import UserNotifications

class ViewNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()//have showed
        center.removeAllPendingNotificationRequests() //not show
        let content_for_clear_badge = UNMutableNotificationContent.init()
        content_for_clear_badge.badge = 0
        let trigger_for_clear = UNTimeIntervalNotificationTrigger.init(timeInterval: 3, repeats: false)
        let requet_for_clear_badge = UNNotificationRequest.init(identifier: "clear", content: content_for_clear_badge, trigger: trigger_for_clear)
        center.add(requet_for_clear_badge) { (clearError) in
            if clearError == nil {
                print("no error in clear error")
            }
            else {
                print("error in clear :\(clearError)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

