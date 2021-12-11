//
//  PostDetailViewTwo.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/08.
//

import SwiftUI
import MapKit
import UIKit

struct PostDetailViewTwo: View {
    @EnvironmentObject var environmentCurrentUser: UserData
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var isShowPostDetailPopover: IsShowPostDetailPopover
    
    @State var selectedPost = Post(omiseName: "", documentId: "", created_at: "", comment: "", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), created_by: "", created_by_name: "", imageURL: "")
    
    @State var isShowingDetailContent: Bool = false
    
    @State var selectedPostImageData: Data?
    @State var selectedPostImageUIImage: UIImage?
    @State var selectedPostUserImageUIImage: UIImage = UIImage(named: "SampleImage")!
    @State var isFavoriteAddedToSelectedPost: Bool = false
    @State var isBookmarkAddedToSelectedPost: Bool = false 
    @State var selectedPostImageURLURL: URL?
    
    //
    @State var showPhoto: Bool = false
    @State var isFavoriteAdded = false
    @State var isBookmarkAdded = false
    
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
                                                                      title: "❤️が送られました",
                                                                      body: "\(selectedPost.comment)",
                                                                      completion: {
                                                    print("プッシュ通知を送りました")
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
                                                                      title: "🔖投稿がブックマークされました",
                                                                      body: "\(selectedPost.comment)",
                                                                      completion: {
                                                    print("プッシュ通知を送りました")
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
                            
                            // その他ボタン
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
                                
                                // Google検索リンクボタン
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
                    .animation(Animation.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5).delay(0.3), value: viewState1)
                    .onAppear {
                        withAnimation {
                            viewState1 = true
                        }
                    }
                } else if isShowingDetailContent == false {
                    // isShowingDetailContent == false の場合
                } // if isShowingDetailContent~ ここまで
            } //ScrollViewここまで
            .onAppear{
                print("PostDetailViewTwoのデータを読み込みます")
                
                let postData = PostData()
                postData.getPostDetail(documentKeyID: isShowPostDetailPopover.selectedPostDocumentUID,
                                       completion: { onePost in
//                    // 削除するパターン分岐に備え、アノテーションを渡しておく
//                    self.parent.selectedPostAnnotation = annotationView
                    // 投稿者名、コメント文などが格納されたドキュメント情報を渡す
                    selectedPost = onePost
                    
                    // お店画像の読み込み（登録がない場合はダミー画像を表示）
                    let postImageURL: URL? = URL(string: onePost.imageURL ?? "")
                    if postImageURL != nil{
                        print("①postImageURL: \(String(describing:postImageURL))を読み込みます")
                        do{
                            selectedPostImageData = try Data(contentsOf: postImageURL!)
                        } catch {
                            print("error")
                        }
                    } else {
                        print("②postImageURLがnilです")
                        selectedPostImageData = nil
                        selectedPostImageUIImage = nil
                    }
                    
                    if selectedPostImageData != nil{
                        print("③")
                        selectedPostImageUIImage = UIImage(data: selectedPostImageData!)!
                    } else {
                        print("④Error")
                        selectedPostImageUIImage = nil
                    }
                    
                    // ファボ、ブックマークの判定
                    print("check start")
                    CheckFavorite(postID: onePost.documentId, currentUserID: environmentCurrentUser.uid, completion: { resultBool, foundedFavID in
                        isFavoriteAddedToSelectedPost = resultBool
//                        FavoriteID = foundedFavID
                        
                        CheckBookmark(postID: onePost.documentId, currentUserID: environmentCurrentUser.uid, completion: { resultBool, foundedBookmarkID in
                            isBookmarkAddedToSelectedPost = resultBool
//                            BookmarkID = foundedBookmarkID
                            
                            getUserImageFromFirestorage(userUID: onePost.created_by ?? "GuestUID") { data in
                                if data != nil {
                                    print("投稿者プロフィール画像を読み込みます：\(data!)")
                                    selectedPostUserImageUIImage = UIImage(data: data!)!
                                } else {
                                    print("\(String(describing: onePost.created_by))の投稿者プロフィール画像が見つかりません")
                                    selectedPostUserImageUIImage = UIImage(named: "SampleImage")!
                                }
                                
                                // 投稿詳細内容を表示
                                isShowingDetailContent = true
                            }
                        })
                    })
                    
                })
                
                print("読み込み完了")
//                isShowingDetailContent = true
            }
            
            // 報告ウィンドウ
            if isShowReportWindow {
                VStack{
                    TextField("報告内容を入力してください", text: $inputReportText).padding()
                    Button("送信"){
                        print("送信します")
                        postData.sendReportText(postUID: selectedPost.documentId, reporterUID: environmentCurrentUser.uid, reportText: inputReportText)
                        isShowReportWindow = false
                    }
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

//struct PostDetailViewTwo_Previews: PreviewProvider {
//    static var previews: some View {
//        PostDetailViewTwo()
//    }
//}
