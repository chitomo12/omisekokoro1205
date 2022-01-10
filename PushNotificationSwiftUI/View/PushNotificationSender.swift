//
//  PushNotificationSender.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/05.
//

import Foundation

class PushNotificationSender {
    init(){}
    private let FCM_ServerKey = FCMServerKey().fcmKey
    private let endpoint = "https://fcm.googleapis.com/fcm/send"
    
    // 指定したデバイスにプッシュ通知を送信するメソッド
    func sendPushNotification(to token: String, userId: String, title: String, body: String, completion: @escaping () -> Void) {
        let serverKey = FCM_ServerKey
        guard let url = URL(string: endpoint) else { return }
        let paramString: [String: Any] = ["to": token,
                                          "notification": ["title": title, "body": body],
                                          "data": ["userId": userId]]
        print("Sender userId is: \(userId)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("key=\(FCM_ServerKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            do {
                if let jsonData = data {
                    if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        print("Received data: \(jsonDataDict)")
                        completion()
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
