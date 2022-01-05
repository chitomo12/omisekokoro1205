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
        
        // Delete all registries
        UIApplication.shared.unregisterForRemoteNotifications()
        print("①isRegisteredForRemoteNotifications: \(UIApplication.shared.isRegisteredForRemoteNotifications)")

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
            guard success else {
                return
            }
            print("success: \(success)")
            print("Success in APNs registry")
            DispatchQueue.main.async {
                print("isRegisteredForRemoteNotifications: \(UIApplication.shared.isRegisteredForRemoteNotifications)")

            }
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("settings: \(settings)")
            print("settings.authorizationStatus: \(settings.authorizationStatus)")
             guard settings.authorizationStatus == .authorized else { return }
        }
        
        application.registerForRemoteNotifications()

//        Messaging.messaging().token { token, error in
//          if let error = error {
//            print("Error fetching FCM registration token: \(error)")
//          } else if let token = token {
//            print("FCM registration token: \(token)")
////            self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
//              // ログイン中のユーザーがいれば、データベースに当該ユーザーのFCMトークンを追加する。
//              if let authCurrentUser = Auth.auth().currentUser {
//                  self.loginController.setFcmTokenToFirestore(
//                      userUid: authCurrentUser.uid,
//                      fcmToken: token) {
//                          print("FCMトークンを更新しました")
//                      }
//              }
//          }
//        }
        
        return true
    }
    
    // アプリ起動時にFcmTokenを取得。その後、Firestoreのユーザーコレクションに保存する。
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        print("didReceiveRegistrationToken fcmToken: \(fcmToken!)")
        messaging.token { token, _ in
            guard let token = token else {
                return
            }
            print("（AppDelegate内）トークン: \(token)")
            // ログイン中のユーザーがいれば、データベースに当該ユーザーのFCMトークンを追加する。
            if let authCurrentUser = Auth.auth().currentUser {
                self.loginController.setFcmTokenToFirestore(
                    userUid: authCurrentUser.uid,
                    fcmToken: token) {
                        print("Firebase上のFCMトークンを更新しました")
                    }
            }
        }
        
        print("isRegisteredForRemoteNotifications: \(UIApplication.shared.isRegisteredForRemoteNotifications)")
    }

    
    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
}

extension AppDelegate {

    // ③ プッシュ通知の利用登録が成功した場合
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("③ プッシュ通知の利用登録が成功した場合")
        print("Device token: \(token)")
        print("isRegisteredForRemoteNotifications: \(UIApplication.shared.isRegisteredForRemoteNotifications)")
        Messaging.messaging().apnsToken = deviceToken
        
//        Messaging.messaging().token { token, error in
//            if let token = token {
//                print("（application(_ application: , didRegisterForRemoteNotificationsWithDeviceToken deviceToken: ) ）トークン: \(token)")
//            }
//        }
    }

    // ④ プッシュ通知の利用登録が失敗した場合
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register to APNs: \(error)")
    }
}


// MARK: - AppDelegate Push Notification
// プッシュ通知のためのextension
extension AppDelegate {
   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       if let messageID = userInfo["gcm.message_id"] {
          print("MessageID: \(messageID)")
       }
       print("userInfo: \(userInfo)")
       completionHandler(.newData)
   }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // ...

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)

        completionHandler()
      }

   // アプリがForeground時にPush通知を受信する処理
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler([.banner, .sound])
   }
}
