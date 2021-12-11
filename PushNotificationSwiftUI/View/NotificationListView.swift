//
//  CommentListView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/07.
//

import SwiftUI
import UIKit
import FirebaseFirestore
import CoreLocation

struct NotificationListView: View {
    
    @EnvironmentObject var environmentCurrentUserData: UserData
    
    @Binding var mapSwitch: MapSwitch
    
    @State var postList: [Post] = []
    @State var notificationList: [NotificationData] = []
    
    // カード表示用のリスト
    @State var notificationCardList: [NotificationCardData] = []
    
    let linearGradientForButton = LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    let pushNotificationSender = PushNotificationSender()
    
    var notificationController = NotificationController()
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let screenWidth = bounds.width
        ScrollView{
            VStack(alignment: .center) {
                
    //            テスト用
    //            Button(action: {
    //                print("プッシュ通知を送ります")
    //                pushNotificationSender
    //                    .sendPushNotification(to:  "czIhz_lX1kjPurs2FDPC0K:APA91bEgZuYuGA_8KUiZvtnPbIu6ctlgvUBx0cYk1suM51i_yTop1WLEOn3l6b-dYzdQOtAGjM5qattdooTFjU8w3uPMUp5Z7KDqHHpYf-KfW9j4n9lh2UCsZv2wsRmysgBjAH7J5ZoU",
    //                                          userId: environmentCurrentUserData.uid,
    //                                          title: "title test", body: "test body") {
    //                        print("プッシュ通知を送りました")
    //                    }
    //            }) {
    //                Text("プッシュ通知を送る")
    //                    .font(.system(size: 16, weight: .bold, design: .rounded))
    //                    .foregroundColor(.white)
    //                    .frame(width: 200, height: 40, alignment: .center)
    //                    .background(linearGradientForButton)
    //                    .cornerRadius(20)
    //                    .padding()
    //            }
            
                Image("omisekokoro_bar")
                    .resizable()
                    .padding(.top, 0.0)
                    .scaledToFit()
                    .frame(height:25)
                Button(action: {
                    notificationCardList = [] // 初期化
                    print("データを取得します...")
                    notificationController.getNotificationCardList(userUID: environmentCurrentUserData.uid) { notificationCardListResult in
                        print("notificationListを取得しました")
                        notificationCardList = notificationCardListResult
                    
                    }
                    print("postList: \(postList)")
                }) {
                    HStack{
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("更新")
                    }
                }
                
                VStack(alignment: .leading) {
                    ForEach(0..<notificationCardList.count, id: \.self) { count in
                        // 投稿をリスト化して表示
                        NotificationCardView(notificationForCard: $notificationCardList[count])
                            .background(Color.white)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .onAppear {
                    if notificationCardList.count == 0 {
                        notificationController.getNotificationCardList(userUID: environmentCurrentUserData.uid) { notificationCardListResult in
                            print("notificationListを取得しました")
                            notificationCardList = notificationCardListResult
                        }
                    }
                }
                
    //            List($notificationCardList){ notificationCard in
    //                 NotificationCardView(notificationForCard: notificationCard)
    //
    ////                VStack(alignment: .leading){
    ////                    Text("\(notificationCard.sendUserUid ?? "")さんからの通知").font(.caption)
    ////                    Text(notificationCard.title)
    ////                    Text(notificationCard.body).font(.caption)
    ////                    Text(notificationCard.created_at).font(.caption2)
    ////                        .padding()
    ////                }
    //            }
            }
            .frame(width: screenWidth)
        }
    }
    
    public func getPostListFromAll(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        
        // Firestoreのセッティング
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        db.collection("locationCollection")
            .document("locationDocument")
            .collection("subLocCollection")
            .order(by: "created_at", descending: true)  // 日付降順で取得
            .limit(to: 5)
            .getDocuments() { (querySnapshot, error) in
                print("get: \(String(describing: querySnapshot!))")
                for document in querySnapshot!.documents {
                    print("document: \(String(describing: document.get("name")))")
                    let postName = String(describing: document.get("name")! )
                    let postCreatedAt = document.get("created_at") as! Timestamp
                    let postCreatedAtDate = postCreatedAt.dateValue()
                    let postCreatedAtString = formatter.string(from: postCreatedAtDate)
                    let postComment = String(describing: document.get("comment")! )
                    let postLatitude = document.get("latitude") as! Double
                    let postLongitude = document.get("longitude") as! Double 
                    postList.append(
                        Post(omiseName: postName,
                             documentId: document.documentID,
                             created_at: postCreatedAtString,
                             comment: postComment,
                             coordinate: CLLocationCoordinate2D(latitude: postLatitude, longitude: postLongitude),
                             created_by: document.get("postUserUID") as! String?,
                             created_by_name: document.get("postUserName") as! String?,
                             imageURL: document.get("imageURL") as! String?
                            )
                    )
                }
                if error != nil {
                    print("error: \(String(describing: error))")
                }
            }
    } // getPostListFromAllここまで
}



struct CommentListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView(mapSwitch: .constant(.normal))
    }
}
