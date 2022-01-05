//
//  NotificationCardView.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/07.
//

import SwiftUI

struct NotificationCardData: Identifiable {
    let id = UUID()
    let senderUserUIImage: UIImage
    let senderUserName: String
    let title: String
    let body: String
    let created_at: String 
}

struct NotificationCardView: View {
    @Binding var notificationForCard: NotificationCardData
    @State var userUIImage = UIImage(named: "SampleImage")
    
    var body: some View {
//        let bounds = UIScreen.main.bounds
//        let screenWidth = bounds.width
        
        // Card表示用のビュー
        VStack(alignment: .leading){
                HStack(alignment: .top){
                    Image(uiImage: notificationForCard.senderUserUIImage)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10))
                    VStack(alignment: .leading) {
                        Text("\(notificationForCard.senderUserName)さんより")
                            .font(.callout)
                            .fontWeight(.medium)
                        Text("\(notificationForCard.title)")
                            .font(.body)
                        Text("\(notificationForCard.body)")
                            .font(.caption)
                            .padding(.top, 1)
                        
                        HStack{
                            Text("\(Image(systemName: "paperplane")) \(notificationForCard.created_at)")
                                .font(.caption)
                        }
                        .padding(.top, 1)
                    }
                }
                .padding()
            Divider()
        }
    }
}

struct NotificationCardView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCardView(notificationForCard: .constant(NotificationCardData(senderUserUIImage: UIImage(named: "SampleImage")!,
                                                                                 senderUserName: "サンプル",
                                                                                 title: "タイトルサンプル",
                                                                                 body: "通知サンプル通知サンプル通知サンプル通知サンプル通知サンプル",
                                                                                 created_at: "2020年1月12日")))
    }
}
