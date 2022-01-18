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
}

class NotificationController: ObservableObject{
    @EnvironmentObject var environmentCurrentUser: UserData
    
    var notificationList: [NotificationData] = []
    var notificationCardList: [NotificationCardData] = []
    
    let formatter = DateFormatter()
    
    let loginController = LoginController()
    
    // Firestoreのセッティング
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
    
    public func getNotificationCardList(userUID: String, completion: @escaping ([NotificationCardData]) -> () ) {
        print("Notification一覧を取得します")
        self.notificationCardList = []
        
        db.collection("notificationCollection")
            .document("notificationDocument")
            .collection("subNotifiCollection")
            .whereField("receiveUserUid", isEqualTo: userUID)
            .order(by: "created_at", descending: true)  // 日付降順で取得
            .limit(to: 10)
            .getDocuments { querySnapshots, error in
                if error == nil && querySnapshots!.documents.count != 0 {
                    print("\(querySnapshots!.documents.count)件の通知を読み込みます")
                    for document in querySnapshots!.documents {
                        
                        // 日付を取得しStringに変換
                        guard let notifiCreatedAt = document.get("created_at") as? Timestamp else { continue }
                        let notifiCreatedAtString = self.formatter.string(from: notifiCreatedAt.dateValue())
                        
                        // UIDからユーザー画像を取得
                        getUserImageFromFirestorage(userUID: document.get("sendUserUid") as! String) { data in
                            var senderUserImage: UIImage = UIImage(named: "SampleImage")!
                            if data != nil {
                                // ユーザー画像を取得できた場合はプロパティに格納する
                                senderUserImage = UIImage(data: data!)!
                            }
                            
                            // UIDから名前を取得
                            self.loginController.getUserNameFromUid(userUid: document.get("sendUserUid") as! String) { nameString in
                                var senderUserName = "ゲスト"
                                if nameString != nil{
                                    senderUserName = nameString!
                                }
                                print("notificationCardListに追加します")
                                print("\(document.get("title") as! String)")
                                self.notificationCardList.append(
                                    NotificationCardData(senderUserUIImage: senderUserImage,
                                                         senderUserName: senderUserName,
                                                         title: document.get("title") as! String,
                                                         body: document.get("body") as! String,
                                                         created_at: notifiCreatedAtString)
                                )
                                // リストに要素を追加するごとに順次並び替えを行う
                                self.notificationCardList = self.notificationCardList.sorted(by: { (a,b) -> Bool in
                                    return a.created_at > b.created_at
                                })
                                completion(self.notificationCardList)
                            }
                            
                        }
                    }
                    print("notificationList: \(self.notificationList)")
                } else if error != nil {
                    print("エラー：\(String(describing: error))")
                } else {
                    print("お知らせはありません")
                }
            }
    }
}
