//
//  AppDelegate.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/10/24.
//

import UIKit
import CloudKit
import Firebase
import FirebaseMessaging

let localFileManager = LocalFileManager.shared
let mlModelManager = MLModelManager.shared
let newsSettingManager = NewsSettingManager.shared
let utils = Utils.shared
let userDefaults = UserDefaults.standard
let userDefaultsWidget = UserDefaults(suiteName: UserdefaultsGroup.widgetShared.rawValue)
let cloudDefaults = NSUbiquitousKeyValueStore.default

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        cloudDefaults.synchronize()
        checkAuthorizationState()
        
        // Firebase file add - GoogleService-Info.plist
//        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// App 在前景時，推播送出時即會觸發的 delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // 印出後台送出的推播訊息(JOSN 格式)
        let userInfo = notification.request.content.userInfo
        print("userInfo: \(userInfo)")
        
        // 可設定要收到什麼樣式的推播訊息，至少要打開 alert，不然會收不到推播訊息
        completionHandler([.badge, .banner, .list])
    }
    
    /// App 在關掉的狀態下或 App 在背景或前景的狀態下，點擊推播訊息時所會觸發的 delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 印出後台送出的推播訊息(JOSN 格式)
        let userInfo = response.notification.request.content.userInfo
        if let urlStr = userInfo["url"] as? String, let url = URL(string: urlStr) {
            UIApplication.shared.urlOpenHandle(url: url)
        }
        
        completionHandler()
    }
}
