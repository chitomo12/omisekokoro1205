//
//  AppDelegate.swift
//  PushNotificationStury
//
//  Created by 福田正知 on 2021/12/04.
//

import Firebase
import FirebaseMessaging
import FirebaseAuth
import UserNotifications
import UIKit

//@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var loginController = LoginController()
    
    @Published var fcmToken: String = "defaultToken"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
            guard success else {
                return
            }
            print("success: \(success)")
            print("Success in APNs registry")
        }
        
        application.registerForRemoteNotifications()
                
        return true
    }
    
    // アプリ起動時にFcmTokenを取得。その後、Firestoreのユーザーコレクションに保存する。
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else {
                return
            }
            print("（AppDelegate内）トークン: \(token)")
            // ログイン中のユーザーがいれば、当該ユーザーのデータベースにFCMトークンを追加する。
            if let authCurrentUser = Auth.auth().currentUser {
                self.loginController.setFcmTokenToFirestore(
                    userUid: authCurrentUser.uid,
                    fcmToken: token) {
                        print("FCMトークンを更新しました")
                    }
            }
        }
        print("messaging: \(messaging)")
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


}

// MARK: - AppDelegate Push Notification
// プッシュ通知のためのextension
extension AppDelegate {
   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       if let messageID = userInfo["gcm.message_id"] {
          print("MessageID: \(messageID)")
       }
       print(userInfo)
       completionHandler(.newData)
   }
   
   // アプリがForeground時にPush通知を受信する処理
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler([.banner, .sound])
   }
}
