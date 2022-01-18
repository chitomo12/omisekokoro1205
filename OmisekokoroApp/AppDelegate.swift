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

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var loginController = LoginController()
    
    @Published var fcmToken: String = "defaultToken"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // APNsへの登録処理
        print("RemoteNotificationの登録を解除します")
        UIApplication.shared.unregisterForRemoteNotifications()

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
            guard success else {
                return
            }
            print("APNsへの登録に成功")
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
        }
        
        print("アプリをRemoteNotificationに登録します")
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // アプリ起動時にFcmTokenを取得。その後、Firestoreのユーザーコレクションに保存する。
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        print("didReceiveRegistrationToken fcmToken: \(fcmToken!)")
        messaging.token { token, error in
            guard let token = token else {
                print("エラー：\(String(describing: error))")
                return
            }
            print("トークンを取得しました: \(token)")
            // ログイン中のユーザーがいれば、データベースに当該ユーザーのFCMトークンを追加する。
            if let authCurrentUser = Auth.auth().currentUser {
                self.loginController.setFcmTokenToFirestore(
                    userUid: authCurrentUser.uid,
                    fcmToken: token) {
                        print("Firebase上のFCMトークンデータを更新しました")
                    }
            }
        }
    }
}

extension AppDelegate {
    // プッシュ通知の利用登録が成功した場合の処理
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("Device token: \(token)")
        // APNsトークンをFCMトークンにマッピングする
        Messaging.messaging().apnsToken = deviceToken
    }

    // プッシュ通知の利用登録が失敗した場合の処理
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("プッシュ通知の利用登録に失敗: \(error)")
    }
        
    // サイレンとプッシュ通知をバックグラウンドで受け取った場合の処理
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo["gcm.message_id"] {
            print("userInfo[\"gcm.message_id\"]: \(messageID)")
        }
        print("userInfo: \(userInfo)")
        completionHandler(.newData)
    }
    
    // 通知をタップした時の処理
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }
    
    // アプリがForeground時にPush通知を受信する処理
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
