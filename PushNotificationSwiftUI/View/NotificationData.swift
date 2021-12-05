//
//  NotificationData.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/05.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct NotificationData: Identifiable{
    let id = UUID()
    let sendUserUid: String?
    let receiveUserUid: String?
    let relatedPostUid: String?
    let title: String
    let body: String
    let created_at: String
}

class NotificationController: ObservableObject{
    @EnvironmentObject var environmentCurrentUser: UserData
    
    var notificationList: [NotificationData] = []
    
    let formatter = DateFormatter()
    
    // Firestoreのセッティング①
    var db: Firestore!
    let settings = FirestoreSettings()
    init(){
        // Firestoreのセッティング②
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
    }
    
    public func addNotificationList(notificationData: NotificationData){
        print("Notificationを追加します")
        
        db.collection("notificationCollection")
            .document("notificationDocument")
            .collection("subNotifiCollection")
            .addDocument(data: [
                "sendUserUid" : notificationData.sendUserUid!,
                "receiveUserUid": notificationData.receiveUserUid!,
                "relatedPostUid": notificationData.relatedPostUid!,
                "title": notificationData.title,
                "body": notificationData.body,
                "created_at": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("エラー：\(error)")
                } else {
                    print("Notificationを追加しました：\(notificationData.title)")
                }
            }
    }
    
    public func getNotificationList(userUID: String, completion: @escaping ([NotificationData]) -> () ) {
        print("Notification一覧を取得します")
        db.collection("notificationCollection")
            .document("notificationDocument")
            .collection("subNotifiCollection")
            .whereField("receiveUserUid", isEqualTo: userUID)
            .getDocuments { querySnapshots, error in
                if error == nil && querySnapshots!.documents.count != 0 {
                    for document in querySnapshots!.documents {
                        
                        guard let notifiCreatedAt = document.get("created_at") as? Timestamp else { continue }
//                        let notifiCreatedAtDate = notifiCreatedAt.dateValue()
                        let notifiCreatedAtString = self.formatter.string(from: notifiCreatedAt.dateValue())
                        
                        self.notificationList.append(
                            NotificationData(sendUserUid: document.get("sendUserUid") as? String,
                                             receiveUserUid: document.get("receiveUserUid") as? String,
                                             relatedPostUid: document.get("relatedPostUid") as? String,
                                             title: document.get("title") as! String,
                                             body: document.get("body") as! String,
                                             created_at: notifiCreatedAtString)
                            )
                    }
                    print("notificationList: \(self.notificationList)")
                } else if error != nil {
                    print("エラー：\(String(describing: error))")
                } else {
                    print("お知らせはありません")
                }
                completion(self.notificationList)
            }
    }
}
