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
    @Binding var notificationCardList: [NotificationCardData]
    
    let linearGradientForButton = LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    let pushNotificationSender = PushNotificationSender()
    
    var notificationController = NotificationController()
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let screenWidth = bounds.width
        ScrollView{
            VStack(alignment: .center) {
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
                    .foregroundColor(Color("ColorFour"))
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
            }
            .frame(width: screenWidth)
        }
    }
    
//    public func getPostListFromAll(){
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
//
//        // Firestoreのセッティング
//        var db: Firestore!
//        let settings = FirestoreSettings()
//        Firestore.firestore().settings = settings
//        db = Firestore.firestore()
//
//        db.collection("locationCollection")
//            .document("locationDocument")
//            .collection("subLocCollection")
//            .order(by: "created_at", descending: true)  // 日付降順で取得
//            .limit(to: 5)
//            .getDocuments() { (querySnapshot, error) in
//                print("get: \(String(describing: querySnapshot!))")
//                for document in querySnapshot!.documents {
//                    print("document: \(String(describing: document.get("name")))")
//                    let postName = String(describing: document.get("name")! )
//                    let postCreatedAt = document.get("created_at") as! Timestamp
//                    let postCreatedAtDate = postCreatedAt.dateValue()
//                    let postCreatedAtString = formatter.string(from: postCreatedAtDate)
//                    let postComment = String(describing: document.get("comment")! )
//                    let postLatitude = document.get("latitude") as! Double
//                    let postLongitude = document.get("longitude") as! Double
//                    postList.append(
//                        Post(omiseName: postName,
//                             documentId: document.documentID,
//                             created_at: postCreatedAtString,
//                             comment: postComment,
//                             coordinate: CLLocationCoordinate2D(latitude: postLatitude, longitude: postLongitude),
//                             created_by: document.get("postUserUID") as! String?,
//                             created_by_name: document.get("postUserName") as! String?,
//                             imageURL: document.get("imageURL") as! String?
//                            )
//                    )
//                }
//                if error != nil {
//                    print("error: \(String(describing: error))")
//                }
//            }
//    } // getPostListFromAllここまで
}



//struct CommentListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationListView(mapSwitch: .constant(.normal))
//    }
//}
