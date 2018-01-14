//
//  AppDelegate.swift
//  ISEE
//
//  Created by 李博闻 on 16/10/21.
//  Copyright © 2016年 小艺艺. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMLParserDelegate {

    var window: UIWindow?

    var result_string = ""
    var elementName: String?
    var attribute:[String: String]?
    var notice_all: [String] = []
    var notice_date: [String] = []
    var notice_link: [String] = []
    var initial_count = 0
    var new_count = 0
    var link_dest = ""
    
    let center_clear = UNUserNotificationCenter.current()
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent.init()
    let content_clear = UNMutableNotificationContent.init()
    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //set fetch time interval
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        //clear all other notification
        center.removeAllDeliveredNotifications()//have showed
        center.removeAllPendingNotificationRequests() //not show
        center_clear.removeAllDeliveredNotifications()
        center_clear.removeAllPendingNotificationRequests()
        //get the require of notification
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, .badge, .sound]) { (aBool, aError) in
            if aError == nil {
                print("no errors in requestAuthorization")
            }else {
                print("errors in requestAuthorization:\(aError)")
            }
        }
        center_clear.requestAuthorization(options: [UNAuthorizationOptions.badge]) { (aBool, aError) in
            if aError == nil {
                print("no errors in requestAuthorization for clear")
            }else {
                print("errors in requestAuthorization for clear:\(aError)")
            }
        }
        //check the status of authorization
        center.getNotificationSettings { (notification) in
            if notification.authorizationStatus == UNAuthorizationStatus.denied {
                print("未响应")
            } else if notification.authorizationStatus == UNAuthorizationStatus.notDetermined {
                print("不确定")
            } else if notification.authorizationStatus == UNAuthorizationStatus.authorized {
                print("已响应")
            } else {
                print("else")
            }
        }
        center_clear.getNotificationSettings { (notification) in
            if notification.authorizationStatus == UNAuthorizationStatus.denied {
                print("未响应clear")
            } else if notification.authorizationStatus == UNAuthorizationStatus.notDetermined {
                print("不确定clear")
            } else if notification.authorizationStatus == UNAuthorizationStatus.authorized {
                print("已响应clear")
            } else {
                print("else")
            }
        }
        //判断是否是第一次启动app
        let everLauched = UserDefaults.standard.bool(forKey: "everLauched")
        if everLauched == false {
            UserDefaults.standard.set(true, forKey: "firstLauched")
            UserDefaults.standard.set(true, forKey: "everLauched")
        }else {
            UserDefaults.standard.set(false, forKey: "firstLauched")
        }
        
        return true
    }
    func printItem(notification: NSNotification) {
        var count: Int?
        count = notification.object as! Int
        print("*******")
        print(count!)
        self.initial_count = count!
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("fetch!!!")
        if self.link_dest != "" {
            attribute?.removeAll()
            notice_all.removeAll()
            notice_date.removeAll()
            notice_link.removeAll()
            getNotice(self.link_dest)
            print("fetch link:\(self.link_dest)")
        }
        print("fetch_init: \(self.initial_count)")
        print("fetch_get:\(self.notice_date.count)")
        if self.new_count > 0 {
            content.badge = self.new_count as NSNumber?
            content.title = self.notice_all[0]
            //print(content.title)
            //content.subtitle = "新通知"
            content.sound = UNNotificationSound.default()
            content.body = self.notice_all[0]
            let request = UNNotificationRequest.init(identifier: "noticeRequest", content: content, trigger: trigger)
            center.add(request) { (rError) in
                if rError != nil {
                    print("error in adding request:\(rError)")
                }else {
                    print("no error in adding request")
                }
            }
        }else {
            //print(self.new_count)
            //print(self.initial_count)
            //print(self.notice_date.count)
        }
    }
    
    func getDataOnline(_ path: String) {
        let url = URL(string: path)
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        do {
            result_string = try NSString(contentsOf: url!, encoding: enc) as String
        }catch let error as NSError {
            print("error in data getting:\(error.description)")
        }
        
    }
    
    func getNotice(_ noticePath: String?) {
        
        if noticePath != nil {
            getDataOnline(noticePath!)
            //print("fetch result:\(result_string)")
            //change & into ********
            var final_result_string = ""
            final_result_string = result_string.replacingOccurrences(of: "&", with: "********")
            final_result_string = final_result_string.replacingOccurrences(of: "height=\"3\"background", with: "height=\"3\" background")
                
            let result_data = final_result_string.data(using: String.Encoding.utf8)
            let parser = XMLParser(data: result_data!)
            parser.delegate = self
            parser.parse()
            
        }
        
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.attribute = attributeDict
        self.elementName = elementName
        //print("\(elementName)'s attribute: \(attributeDict)")
        //add title and link
        let linkPattern = "^redir\\.php\\?catalog_id\\=\\d{5,}\\*{8}object_id\\=\\d{5,}$"
        let regex_link = MyRegex(linkPattern)
        if elementName == "a" && attributeDict["title"] != nil && regex_link.match(attributeDict["href"]!) {
            let title = self.attribute!["title"]!
            let finalTitle = title.replacingOccurrences(of: "********", with: "&")
            self.notice_all.append(finalTitle)
            let currentLink = attributeDict["href"]?.replacingOccurrences(of: "********", with: "&")
            self.notice_link.append(currentLink!)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let currentDate = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "[yyyy-MM-dd]"
        let dateForToday = dateFormat.string(from: currentDate)
        //add date array
        let datePattern = "^\\[\\d{4}\\-\\d{2}\\-\\d{2}\\]$"
        let regex_date = MyRegex(datePattern)
        if self.elementName == "td" && self.attribute!["width"] != nil && self.attribute!["align"] != nil && self.attribute!["style"] != nil && regex_date.match(string) {
            if string == dateForToday {
                self.notice_date.append(string)
            }
        }
        self.new_count = self.notice_date.count - self.initial_count
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        NotificationCenter.default.addObserver(self, selector: #selector(printItem(notification:)), name: NSNotification.Name.init(rawValue: "initial_count"), object: nil)
        //every time quit the app, clear the badge number
        
        content_clear.title = "title"
        content_clear.badge = 0
        print("enter background")
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        center_clear.removeAllPendingNotificationRequests()
        center_clear.removeAllDeliveredNotifications()
        let requet_for_clear_badge = UNNotificationRequest.init(identifier: "clear", content: content_clear, trigger: trigger)
        center_clear.add(requet_for_clear_badge) { (clearError) in
            if clearError == nil {
                print("no error in clear error")
            }
            else {
                print("error in clear :\(clearError)")
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func setLink(notification: NSNotification) {
        self.link_dest = notification.object as! String
        
        print(self.link_dest)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.addObserver(self, selector: #selector(setLink(notification:)), name: NSNotification.Name.init(rawValue: "link"), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

