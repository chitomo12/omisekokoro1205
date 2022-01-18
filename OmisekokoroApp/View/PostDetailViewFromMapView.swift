//
//  PostDetailView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/26.
//

import SwiftUI
import MapKit
import UIKit

// Mapでアノテーション選択時に表示されるビュー
struct PostDetailViewFromMapView: View {
    @EnvironmentObject var environmentCurrentUser: UserData
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var isShowPostDetailPopover: IsShowPostDetailPopover
    
    @Binding var selectedPost: Post
    @Binding var isShowingDetail: Bool
    
    @Binding var isShowingDetailContent: Bool
    
    @Binding var selectedPostImageData: Data?
    @Binding var selectedPostImageUIImage: UIImage?
    @Binding var selectedPostUserImageUIImage: UIImage
    @Binding var isFavoriteAddedToSelectedPost: Bool
    @Binding var isBookmarkAddedToSelectedPost: Bool
    @State var selectedPostImageURLURL: URL?
    
    //
    @State var showPhoto: Bool = false
//    @State var isFavoriteAdded = false
//    @State var isBookmarkAdded = false
    
    @State var viewState1: Bool = false
    @State var isShowActionSheet: Bool = false
    @State var isShowReportWindow: Bool = false
    @State var inputReportText: String = ""
    
    @State var postData = PostData()
    
    @State var pushNotificationSender = PushNotificationSender()
    @State var notificationController = NotificationController()
    
    var body: some View {
//        let bounds = UIScreen.main.bounds
//        let screenWidth = bounds.width
        let triangleHeight = 15.0
    
        ZStack{
            ScrollView{
//            VStack(alignment: .center){
                
                // 投稿内容(表示データを読み込み中はローディングを表示する）
                if isShowingDetailContent == true {
                    // URLが有効な場合、お店画像を表示する
                    if selectedPostImageUIImage != nil{
                        ZStack{
                            Image(uiImage: selectedPostImageUIImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                                .border(Color.white, width: 10)
                                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 3)
                                .ignoresSafeArea()
                        }
                        .rotationEffect(.degrees(showPhoto ? 9 : -90), anchor: .center)
                        .offset(x: 0, y: showPhoto ? 70 : -400)
                        .animation(Animation.easeInOut(duration: 0.5), value: showPhoto)
                        .onAppear{
                            showPhoto = true
                        }
                        .onDisappear{
                            showPhoto = false
                        }
                        Spacer(minLength: 50.0)
                    } else {
                        Spacer(minLength: 200)
                    } // if selectedPostImageUIImage ~~ ここまで
                
                    Group{
                        VStack(alignment: .center, spacing: 0) {
                            Text("\(selectedPost.comment)")
                                .font(.title2)
                                .padding()
                                .background(Color("CalloutColor"))
                                .cornerRadius(15)
                            
                            Path{ path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: triangleHeight, y: triangleHeight))
                                path.addLine(to: CGPoint(x: triangleHeight*2, y: 0))
                                path.addLine(to: CGPoint(x: 0, y: 0))
                            }
                            .fill(Color("CalloutColor"))
                            .frame(width:triangleHeight*2, height: triangleHeight)
                            .offset(x: 0, y: 0)
                        }
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 3)
                        .padding(.horizontal)
                        
                        VStack(alignment: .center){
                            // 投稿者のプロフィール画像（投稿者IDからURLを作ってダウンロードする）
                            Image(uiImage: selectedPostUserImageUIImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50, alignment: .center)
                                .clipShape(Circle())
                            Text("\(selectedPost.created_by_name ?? "")")
                        }
                        .padding(.bottom, 10)
                            
                        HStack {
                            Image(systemName: "paperplane")
                            Text("\(selectedPost.created_at)")
                        }
                        .font(.caption)
                        .padding(.bottom, 20)
                        
                        HStack(spacing:10){
                            // Favボタン
                            Button(action:{
                                if isFavoriteAddedToSelectedPost == false{
                                    // お気に入りされてない場合の処理
                                    // お気に入りに追加
                                    AddFavorite(postID: selectedPost.documentId, userID: environmentCurrentUser.uid, completion: {
                                        isFavoriteAddedToSelectedPost.toggle()
                                        
                                        // 投稿者のFCMトークンを取得
                                        var posterFcmToken: String = "dummy"
                                        environmentCurrentUser.getFcmTokenFromUserUID(userUID: selectedPost.created_by!) { result in
                                            posterFcmToken = result
                                            print("posterFcmToken: \(posterFcmToken)")
                                            // 取得したFCMトークンを使いプッシュ通知を送る
                                            pushNotificationSender.sendPushNotification(to: posterFcmToken,
                                                                      userId: environmentCurrentUser.uid,
                                                                      title: "\(environmentCurrentUser.userName!)さんから❤️が送られました",
                                                                      body: "\(selectedPost.comment)",
                                                                      completion: {
                                                    print("プッシュ通知を送りました -> \(environmentCurrentUser.userName!)さんから❤️が送られました")
                                                })
                                            
                                            // お知らせ一覧に追加する
                                            notificationController.addNotificationList(
                                                notificationData: NotificationData(sendUserUid: environmentCurrentUser.uid,
                                                                                   receiveUserUid: selectedPost.created_by,
                                                                                   relatedPostUid: selectedPost.documentId,
                                                                                   title: "❤️が送られました",
                                                                                   body: "\(selectedPost.comment)")
                                            )
                                        }
                                    }
                                   )
                                } else {
                                    // お気に入りがある場合の処理
                                    RemoveFavorite(postID: selectedPost.documentId, userID: environmentCurrentUser.uid, completion: {
                                        isFavoriteAddedToSelectedPost.toggle()
                                    })
                                }
                            }){
                                VStack {
                                    Image(systemName: isFavoriteAddedToSelectedPost ? "heart.fill" : "heart")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:20)
                                    Text("気になる")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(isFavoriteAddedToSelectedPost ? .pink : .gray)
                                .padding(.all, 10)
                                .frame(width:100)
                                .cornerRadius(20)
                                .animation(Animation.easeInOut, value: isFavoriteAddedToSelectedPost)
                            }
                            
                            // Bookmarkボタン
                            Button(action:{
                                if isBookmarkAddedToSelectedPost == false{
                                    // ブックマークされてない場合の処理
                                    AddBookmark(postID: selectedPost.documentId, userID: environmentCurrentUser.uid, completion: {
                                        isBookmarkAddedToSelectedPost.toggle()
                                        
                                        // 投稿者のFCMトークンを取得
                                        var posterFcmToken: String = "dummy"
                                        environmentCurrentUser.getFcmTokenFromUserUID(userUID: selectedPost.created_by!) { result in
                                            posterFcmToken = result
                                            print("posterFcmToken: \(posterFcmToken)")
                                            // 取得したFCMを使いプッシュ通知を送る
                                            pushNotificationSender.sendPushNotification(to: posterFcmToken,
                                                                      userId: environmentCurrentUser.uid,
                                                                      title: "\(environmentCurrentUser.userName!)さんが🔖投稿をブックマークしました",
                                                                      body: "\(selectedPost.comment)",
                                                                      completion: {
                                                    print("プッシュ通知を送りました -> \( environmentCurrentUser.userName!)さんが🔖投稿をブックマークしました")
                                                })
                                            // お知らせ一覧に追加する
                                            notificationController.addNotificationList(
                                                notificationData: NotificationData(sendUserUid: environmentCurrentUser.uid,
                                                                                   receiveUserUid: selectedPost.created_by,
                                                                                   relatedPostUid: selectedPost.documentId,
                                                                                   title: "🔖投稿がブックマークされました",
                                                                                   body: "\(selectedPost.comment)")
                                            )
                                        }
                                    })
                                } else {
                                    // ブックマークがある場合の処理
                                    RemoveBookmark(postID: selectedPost.documentId, userID: environmentCurrentUser.uid, completion: {
                                        isBookmarkAddedToSelectedPost.toggle()
                                    })
                                }
                            }){
                                VStack {
                                    Image(systemName: isBookmarkAddedToSelectedPost ? "bookmark.fill" : "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:20)
                                    Text("行きたい")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(isBookmarkAddedToSelectedPost ? .yellow : .gray)
                                .padding(.all, 10)
                                .frame(width:100)
                                .cornerRadius(20)
                                .animation(Animation.easeInOut, value: isBookmarkAddedToSelectedPost)
                            }
                            
                            Button(action: {
                                isShowActionSheet = true
                            }){
                                VStack(alignment: .center) {
                                    Image(systemName: "ellipsis")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height:20)
                                    Text("etc.")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.gray)
                                .padding(.all, 10)
                                .frame(width:100)
                                .cornerRadius(20)
                            }
                            
                            .confirmationDialog("etc.", isPresented: $isShowActionSheet, actions: {
                                Button("報告する", role: .none, action: {
                                    print("報告します")
                                    isShowReportWindow = true
                                })
                                Button("閉じる", role: .cancel, action: {
                                    print("閉じます")
                                })
                            })
                        }
                        .padding(.horizontal, 0)
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .center) {
                                HStack {
                                    Image(systemName: "house.fill")
                                    Text(selectedPost.omiseName)
                                }
                                .padding(.horizontal)
                                
                                Button(action:{
                                    // URLが有効な場合Safariで開く
                                    let encodedUrlString = selectedPost.omiseName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                                    if let omiseUrl = URL(string: "https://www.google.com/search?q=\(encodedUrlString!)"){
                                        UIApplication.shared.open(omiseUrl, options: [.universalLinksOnly: false], completionHandler: { completed in
                                            print(completed)
                                        })
                                    }
                                }){
                                    Text("お店を調べる")
                                        .foregroundColor(Color.blue)
                                        .padding(10)
                                        .frame(width: 160)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                }
                                .padding()
                            }
                            .padding(.all, 20)
                        }
                        .frame(width: UIScreen.main.bounds.width)
                    } //Groupここまで
                    .opacity(viewState1 ? 1 : 0)
                    .offset(x: 0, y: viewState1 ? 0 : -25)
                    .animation(Animation.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5).delay(0.2), value: viewState1)
                    .onAppear {
                        withAnimation {
                            viewState1 = true
                        }
                    }
                } else {
                    // isShowingDetailContent == false の場合
                } // if isShowingDetailContent~ ここまで
                
            } //ScrollViewここまで
            
            if isShowReportWindow {
                VStack{
                    TextField("報告内容を入力してください", text: $inputReportText).padding()
                    Button("送信"){
                        print("送信します")
                        postData.sendReportText(postUID: selectedPost.documentId, reporterUID: environmentCurrentUser.uid, reportText: inputReportText)
                        isShowReportWindow = false
                    }
                    .padding()
                    Button("キャンセル"){
                        isShowReportWindow = false
                        inputReportText = ""
                    }
                }
                .frame(width: 240, height: 300, alignment: .center)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 1)
                .offset(x:0, y:isShowReportWindow ? 0 : -100)
                .opacity(isShowReportWindow ? 1 : 0)
                .animation(Animation.spring(), value: isShowReportWindow)
                
            }
            
            // 投稿内容ロード中に表示するProgressView
            ProgressView()
                .opacity(isShowingDetailContent ? 0 : 1)
                .animation(Animation.easeInOut, value: isShowingDetailContent)
        } //ZStackここまで
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // ImageURLが存在するパターン
        PostDetailViewFromMapView(selectedPost:
                            .constant(Post(omiseName: "サンプル焼き肉店名",
                                           documentId: "sample ID",
                                           created_at: "2020年10月20日",
                                           comment: "眺めが最高でした！",
                                           coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                           created_by: "sampleUserId",
                                           created_by_name: "サンプルユーザー",
                                           imageURL: "https://rimage.gnst.jp/rest/img/hjxxuksz0000/s_005m.jpg")),
                       isShowingDetail: .constant(true),
                       isShowingDetailContent: .constant(true),
                       selectedPostImageData: .constant(try? Data(contentsOf: URL(string: "https://rimage.gnst.jp/rest/img/hjxxuksz0000/s_005m.jpg")!)),
                       selectedPostImageUIImage: .constant(UIImage(named: "emmy")),
                       selectedPostUserImageUIImage: .constant(UIImage(named: "emmy")!),
                       isFavoriteAddedToSelectedPost: .constant(true),
                       isBookmarkAddedToSelectedPost: .constant(true)
        )
    }
    
}
