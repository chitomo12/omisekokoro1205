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
}

