//
//  MyPageDesign.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/20.
//

import SwiftUI
import UIKit
import MapKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct MyPageDesignView: View {
    @EnvironmentObject var environmentCurrentUserData: UserData
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var isGuestMode: IsGuestMode
    
    @ObservedObject var currentUser: UserData
    
    @Binding var mapSwitch: MapSwitch
    
    // 編集ボタン
    @State var isShowEditPopover: Bool = false
    @State var inputText: String = ""
    
    @State var isShowPHPicker: Bool = false
    @State var newProfileImage: UIImage? = nil
    @State var selectedImage: UIImage? = nil
    
    @State var myPageTabSelection = 0
    
    @State var postedPostCardList: [PostForCard] = []
    // ブックマークしたポストを格納する配列
    @State var bookmarkedPostCardList: [PostForCard] = []
    
    //
    @State var isMyPostsListInitialized = false
    @State var isMyBookmarkListInitialized = false
    
    @State var isShowLoginView = false
    @Binding var isShowLoginCheckView: Bool
    
    @State var isShowNameRegisterPopover = false
    
    @State var rectangleLocationX: CGFloat = -100
    @State var rectangleLocationY: CGFloat = -100
    @State var toukouFrameLocation: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State var toukouFrameSize: CGSize = CGSize(width: 0.0, height: 0.0)
    @State var bookmarkFrameLocation: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State var bookmarkFrameSize: CGSize = CGSize(width: 0.0, height: 0.0)
    
    @State var tabsLabelTextColor = Color.white
    @State var postTabLabelTextColor = Color("ColorThree")
    @State var bookmarkTabLabelTextColor = Color("ColorThree")
    
    @State var movingRectPoint = CGPoint(x: 0.0, y: 0.0)
    
    let loginController = LoginController()
    let linearGradientForButton = LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    var body: some View {
        // 画面幅サイズを取得
        let bounds = UIScreen.main.bounds
        let screenWidth = bounds.width
        
        ZStack{
            ScrollView{
            VStack {
                // ヘッダーバー
                Image("omisekokoro_bar")
                    .resizable()
                    .padding(.top, 0.0)
                    .scaledToFit()
                    .frame(height:25)
                HStack {
                    Image(systemName: "house.fill")
                        .foregroundColor(Color("ColorThree"))
                    Text("マイページ")
                        .font(.title)
                        .fontWeight(.light)
                        .foregroundColor(Color("ColorThree"))
                        .padding(.vertical)
                }
                
                // ユーザーイメージ
                ZStack {
                    LinearGradient(colors: [Color("ColorOne"),Color("ColorTwo")], startPoint: .bottomLeading, endPoint: .topTrailing)
                        .frame(width: screenWidth, height:100)
                        .clipped()
                        .opacity(0.5)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 150)
                    
                    // ユーザーのイメージ
                    Image(uiImage: environmentCurrentUserData.profileUIImage!)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 120, height: 120)
                        .shadow(radius: 3)
                        .padding()
                    
                    // 編集ボタン
                    Button(action: {
                        print("environmentCurrentUserData.userName: \(environmentCurrentUserData.userName)")
                        if isGuestMode.guestModeSwitch == false && environmentCurrentUserData.userName != nil {
                            // ログイン中＆ユーザー名登録済みの場合は編集画面を表示
                            // 編集画面で表示する現在のプロフィール画像を渡す
                            isShowEditPopover = true
                        } else if environmentCurrentUserData.userName == nil {
                            // ユーザー名登録画面を表示
                            isShowNameRegisterPopover = true
                        } else {
                            // ゲストモード中はログイン画面を表示
                            isShowLoginCheckView = true
                        }
                    }) {
                        ZStack{
                            Circle()
                                .foregroundColor(.white)
                                .frame(width:35, height: 35)
                                .shadow(color: .gray, radius: 3)
                                
                            Image(systemName: "pencil")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.gray)
                                .frame(width:18, height: 18)
                        }
                    }
                    .offset(x: 50, y: 40)
                    
                    // プロフィール編集用ポップオーバー
                    .popover(isPresented: $isShowEditPopover) {
                        NavigationView {
                            VStack {
                                Text("プロフィールを編集")
                                    .font(.title)
                                    .fontWeight(.light)
                                    .padding()
                                
                                Text("プロフィール画像")
                                // 最初は現在のプロフィール画像を読み込んで表示する。
                                // PHPickerで写真を選択後は選択した画像を表示する。
                                if selectedImage != nil{
                                    Image(uiImage: selectedImage!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100, alignment: .center)
                                        .cornerRadius(10)
                                        .shadow(color: .gray, radius: 3, x: 0, y: 1)
                                } else {
                                    Image(uiImage: environmentCurrentUserData.profileUIImage!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100, alignment: .center)
                                        .cornerRadius(10)
                                        .shadow(color: .gray, radius: 3, x: 0, y: 1)
                                }
                                
                                Button(action: {
                                    print("画像を選択します")
                                    isShowPHPicker = true
                                }){
                                    RedButtonView(buttonText: "画像を選択")
                                }
                                
                                // ライブラリから写真を選択ビュー
                                .sheet(isPresented: $isShowPHPicker){
                                    PHPickerView(isShowPHPicker: $isShowPHPicker, selectedImage: $selectedImage)
                                }
                                
                                Button(action: {
                                    isShowProgress.progressSwitch = true
                                    print("画像をアップロードします")
                                    if selectedImage != nil{
                                        uploadImageToFirestorage(userUID: environmentCurrentUserData.uid, newImageUIImage: selectedImage!, completion: { _ in
                                            print("アップロード完了")
                                            // プロフィール画像のビューを更新
                                            environmentCurrentUserData.profileUIImage = selectedImage!
                                            isShowProgress.progressSwitch = false
                                        })
                                    } else {
                                        print("選択された画像がありません")
                                        isShowProgress.progressSwitch = false
                                    }
                                }){
                                    RedButtonView(buttonText: "画像を保存")
                                }
                                .padding(.bottom)
                                
                                Text("ユーザー名")
                                TextField("ユーザー名",
                                          text: $inputText,
                                          prompt: Text("ユーザー名を入力してください")
                                )
                                    .padding(.horizontal)
                                    .onAppear{
                                        inputText = environmentCurrentUserData.userName!
                                    }
                                Divider()
                                Button(action: {
                                    isShowProgress.progressSwitch = true
                                    print("保存ボタンが押されました")
                                    
                                    if inputText.isEmpty == false && inputText != environmentCurrentUserData.userName! {
                                        print("ユーザー名を\(environmentCurrentUserData.userName!)から\(inputText)に変更します")
                                        // ユーザー名変更のための処理
                                        environmentCurrentUserData.ChangeUserName(userUID: environmentCurrentUserData.uid, userNewName: inputText, completion: {
                                            environmentCurrentUserData.userName = inputText
                                        })
                                    }
                                    
                                    print("画像をアップロードします")
                                    if selectedImage != nil{
                                        uploadImageToFirestorage(userUID: environmentCurrentUserData.uid, newImageUIImage: selectedImage!, completion: { _ in
                                            print("アップロード完了")
                                            // プロフィール画像のビューを更新
                                            environmentCurrentUserData.profileUIImage = selectedImage!
                                            isShowProgress.progressSwitch = false
                                        })
                                    } else {
                                        print("選択された画像がありません")
                                        isShowProgress.progressSwitch = false
                                    }
                                    
//                                    isShowProgress.progressSwitch = false
                                }) {
//                                    Text("保存")
                                    RedButtonView(buttonText: "保存")
                                }
                                
                                // ログアウトボタン
                                Button(action: {
                                    loginController.logoutUser()
                                    // ユーザー情報をゲスト用に更新
                                    environmentCurrentUserData.uid = "GuestUID"
                                    environmentCurrentUserData.email = "guest@email"
                                    environmentCurrentUserData.userName = "Guest"
                                    environmentCurrentUserData.profileUIImage = UIImage(named: "SampleImage")
                                    // 読み込んだリストを初期化
                                    postedPostCardList = []
                                    bookmarkedPostCardList = []
                                    
                                    // ゲストモードをtrueに
                                    isGuestMode.guestModeSwitch = true
                                    
                                    // 編集画面を閉じる
                                    isShowEditPopover = false
//                                    // ログイン画面へ
//                                    isShowLoginView = true
                                }) {
                                    Text("ログアウトする")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 180, height: 40, alignment: .center)
                                        .background(linearGradientForButton)
                                        .cornerRadius(20)
                                        .padding()
                                }
                            }
//                            NavigationLink(destination: AuthTest(loginController: loginController,
//                                                                 isShowLoginCheckView: $isShowLoginCheckView,
//                                                                 currentUser: currentUser).navigationBarHidden(true),
//                                           isActive: $isShowLoginView) {
//                                EmptyView()
//                            }
                        }
                    }
                    
                    // ユーザー名登録用ポップオーバー
                    .popover(isPresented: $isShowNameRegisterPopover) {
                        NavigationView{
                            NameRegisterView(currentUser: environmentCurrentUserData)
                        }
                    }
                }
                
                // Welcomeテキスト
                Text("\(environmentCurrentUserData.userName ?? "Guest")さん\nいらっしゃい🍲")
                    .fontWeight(.thin)
                    .padding()
                
                // ゲストモードの場合はログインボタンを表示
                if environmentCurrentUserData.uid == "GuestUID"{
                    Button(action:{
                        print("Login")
                        isShowLoginCheckView = true
                    }) {
                        Text("ログインする")
                    }
                }
                
                Divider()
                
                ZStack{
                    Rectangle()
                        .frame(width: 120, height: 60)
                        .cornerRadius(30)
                        .foregroundColor(Color("ColorThree"))
                        .position(x: rectangleLocationX, y: rectangleLocationY + 8)
                        
                    HStack(spacing: 0.0) {
                        
                        GeometryReader{ buttonOneGeo in
                            Button(action:{
                                // 投稿一覧を表示させる
                                myPageTabSelection = 0
                                withAnimation(.spring()) {
                                    rectangleLocationX = toukouFrameLocation.x
                                    rectangleLocationY = toukouFrameLocation.y
                                    postTabLabelTextColor = Color.white
                                    bookmarkTabLabelTextColor = Color("ColorThree")
                                }
                            }){
                                VStack(alignment: .center) {
                                    Image(systemName: "bubble.left.and.bubble.right.fill").font(.caption)
                                    Text("投稿").font(.body)
                                }
                                .foregroundColor(postTabLabelTextColor)
                                .frame(width: UIScreen.main.bounds.width / 2, height: 80)
                                .task{
                                    toukouFrameLocation = CGPoint(x: buttonOneGeo.frame(in: .local).midX, y: buttonOneGeo.frame(in: .local).midY)
                                    toukouFrameSize = CGSize(width: buttonOneGeo.frame(in: .local).width, height: buttonOneGeo.frame(in: .local).height)
                                    if rectangleLocationX == -100 {
                                        postTabLabelTextColor = Color.white
                                        // タブボタン背景のRectangleの初期値を設定
                                        rectangleLocationX = toukouFrameLocation.x
                                        rectangleLocationY = toukouFrameLocation.y
                                    }
                                }
                            }
//                            .frame(width:180, height: 80)
//                            .border(Color.gray)
                        }
                        
                        GeometryReader{ buttonTwoGeo in
                            Button(action: {
                                // ブックマーク一覧を表示させる
                                myPageTabSelection = 1
                                withAnimation(.spring()) {
                                    rectangleLocationX = bookmarkFrameLocation.x + (toukouFrameSize.width + bookmarkFrameSize.width) / 2
                                    rectangleLocationY = bookmarkFrameLocation.y
                                    bookmarkTabLabelTextColor = Color.white
                                    postTabLabelTextColor = Color("ColorThree")
                                }
                            }) {
                                VStack(alignment: .center) {
                                    Image(systemName: "bookmark.fill").font(.caption)
                                    Text("ブックマーク").font(.body)
                                }
                                .foregroundColor(bookmarkTabLabelTextColor)
                                .frame(width:180, height: 80)
                            }
                            .frame(width: UIScreen.main.bounds.width / 2, height: 80)
                            .onAppear {
                                bookmarkFrameLocation = CGPoint(x: buttonTwoGeo.frame(in: .local).midX, y: buttonTwoGeo.frame(in: .local).midY)
                                bookmarkFrameSize = CGSize(width: buttonTwoGeo.frame(in: .local).width, height: buttonTwoGeo.frame(in: .local).height)
                            }
                        }
                    }
                }
//                .border(Color.gray)
                                
                if isGuestMode.guestModeSwitch == true {
//                    // ゲストモードの場合

                } else {
                    // ゲストモードでない場合
                    if myPageTabSelection == 0 {
                        // 投稿タブを選択した場合
                        HStack{
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("再読み込み")
                                .font(.callout)
                                .padding(.vertical)
                                .onAppear{
                                    if isMyPostsListInitialized == false{
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                            // 投稿一覧を読み込み
                                            getUserPostedPosts(userUID: environmentCurrentUserData.uid)
                                            isMyPostsListInitialized = true
                                        }
                                    }
                                }
                                .onTapGesture {
                                    // 投稿一覧を読み込み
                                    getUserPostedPosts(userUID: environmentCurrentUserData.uid)
                                }
                        }
                        .foregroundColor(Color("ColorThree"))
                        
                        VStack {
                            ForEach(0..<postedPostCardList.count, id: \.self) { count in
                                // 投稿をリスト化して表示
                                PostCardViewTwo(post: $postedPostCardList[count])
                            }
                        }
                        
                    } else if myPageTabSelection == 1 {
                        // ブックマークタブを選択した場合
                        HStack{
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("再読み込み")
                                .font(.callout)
                                .padding(.vertical)
                                .onAppear{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                        if isMyBookmarkListInitialized == false{
                                            // ブックマーク一覧を読み込み
                                            getUserRegisteredBookmarks(userUID: environmentCurrentUserData.uid)
                                            isMyBookmarkListInitialized = true
                                        }
                                    }
                                }
                                .onTapGesture {
                                    // ブックマーク一覧を読み込み
                                    getUserRegisteredBookmarks(userUID: environmentCurrentUserData.uid)
                                }
                        }
                        .foregroundColor(Color("ColorThree"))
                        
                        VStack {
                            ForEach(0..<bookmarkedPostCardList.count, id: \.self) { count in
                                // ブックマークをリスト化して表示
                                PostCardViewTwo(post: $bookmarkedPostCardList[count])
                            }
                        }
                    }
                }
            }
            .frame(width: screenWidth)
        }
        }
    }
    
    public func getUserPostedPosts(userUID: String){
        print("\(userUID)の投稿を探します")
        isShowProgress.progressSwitch = true

        // リストを初期化
        postedPostCardList.removeAll()
        
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
            .whereField("postUserUID", isEqualTo: environmentCurrentUserData.uid)
//            .limit(to: 10)
            .getDocuments() { (querySnapshot, error) in
                if querySnapshot!.count != 0 {
                    print("\(querySnapshot!.count)件の投稿が見つかりました")
                    for document in querySnapshot!.documents {
                        let postName = String(describing: document.get("name")! )
                        let postCreatedAt = document.get("created_at") as! Timestamp
                        let postCreatedAtDate = postCreatedAt.dateValue()
                        let postCreatedAtString = formatter.string(from: postCreatedAtDate)
                        let postComment = String(describing: document.get("comment")! )
                        let postLatitude = document.get("latitude") as! Double
                        let postLongitude = document.get("longitude") as! Double
                        
                        // カード用の構造体postCardListにデータを格納（試験）
                        //   Postのリストとの違いはUIImageのプロパティがあること。
                        var postImageUIImage: UIImage? = UIImage(named: "emmy")
                        // imageURLのnilチェック
                        if let tempImageURL: String = document.get("imageURL") as! String? {
                            print("post.imageURL: \(tempImageURL)")
                            // オプショナルバインディング
                            if let tempImageURLURL = URL(string: tempImageURL){
                                print("tempImageDataURLURL: \(tempImageURLURL)")
                                if let tempImageData = try? Data(contentsOf: tempImageURLURL) {
                                    postImageUIImage = UIImage(data: tempImageData)!
                                }
                            } else {
                                print("tempImageDataURLURL is nil")
                            }
                        } else {
                            print("post.imageURL is nil")
                        }
                        // 投稿者のプロフィール画像を取得
                        var userImageUIImage = UIImage(systemName: "person")
                        getUserImageFromFirestorage(userUID: document.get("postUserUID") as! String) { data in
                            if data != nil {
                                print("投稿者画像を読み込みました：\(data!)")
                                userImageUIImage = UIImage(data: data!)
                            } else {
                                print("投稿者画像が見つかりません")
                            }
                            postedPostCardList.append(
                                PostForCard(omiseName: postName,
                                     documentId: document.documentID,
                                     created_at: postCreatedAtString,
                                     comment: postComment,
                                     coordinate: CLLocationCoordinate2D(latitude: postLatitude,
                                                                        longitude: postLongitude),
                                     created_by: document.get("postUserUID") as! String?,
                                     created_by_name: document.get("postUserName") as! String?,
                                     imageURL: document.get("imageURL") as! String?,
                                     imageUIImage: postImageUIImage,
                                     userImageUIImage: userImageUIImage!
                                    )
                            )
                            // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                            postedPostCardList = postedPostCardList.sorted(by: { (a,b) -> Bool in
                                return a.created_at > b.created_at
                            })
                            isShowProgress.progressSwitch = false
                        }
                    }
                } else {
                    print("投稿が見つかりませんでした")
                    isShowProgress.progressSwitch = false
                }
                
                if error != nil {
                    print("error: \(String(describing: error))")
                }
            }
    }
    
    public func getUserRegisteredBookmarks(userUID: String){
        print("\(userUID)が登録したブックマークを探します")
        isShowProgress.progressSwitch = true

        // リストを初期化
        bookmarkedPostCardList.removeAll()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        
        // Firestoreのセッティング
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        //ブックマークを取得
        db.collection("bookmarkCollection")
            .document("bookmarkDocument")
            .collection("subBookmarkCollection")
            .whereField("userID", isEqualTo: environmentCurrentUserData.uid)
            .getDocuments { bookmarksQuerySnapshot, error in
                if bookmarksQuerySnapshot!.count != 0{
                    print("\(bookmarksQuerySnapshot!.count)件のブックマークが見つかりました")
                    for bookmarkDocument in bookmarksQuerySnapshot!.documents {
                        db.collection("locationCollection")
                            .document("locationDocument")
                            .collection("subLocCollection")
                            .document(bookmarkDocument.get("postID") as! String)
                            .getDocument { documentSnapshot, error in
                                // 削除されているならスキップする
                                if documentSnapshot!.get("name") != nil {
                                    print("documentID: \(documentSnapshot?.documentID)")
                                    // ドキュメントごとの処理を行う
                                    // bookmarkedPostCardListに追加する
                                    let postName = String(describing: documentSnapshot!.get("name") as! String)
                                    let postCreatedAt = documentSnapshot!.get("created_at") as! Timestamp
                                      let postCreatedAtDate = postCreatedAt.dateValue()
                                        let postCreatedAtString = formatter.string(from: postCreatedAtDate)
                                    let postComment = String(describing: documentSnapshot!.get("comment")! )
                                    let postLatitude = documentSnapshot!.get("latitude") as! Double
                                    let postLongitude = documentSnapshot!.get("longitude") as! Double
                                    
                                    // カード用の構造体postCardListにデータを格納（試験）
                                    //   Postのリストとの違いはUIImageのプロパティがあること。
                                    var postImageUIImage: UIImage? = UIImage(named: "emmy")
                                    // imageURLのnilチェック
                                    if let tempImageURL: String = documentSnapshot!.get("imageURL") as! String? {
                                        print("post.imageURL: \(tempImageURL)")
                                        // オプショナルバインディング
                                        if let tempImageURLURL = URL(string: tempImageURL){
                                            if let tempImageData = try? Data(contentsOf: tempImageURLURL) {
                                                postImageUIImage = UIImage(data: tempImageData)!
                                            }
                                        } else {
                                            print("tempImageDataURLURL is nil")
                                        }
                                    } else {
                                        print("post.imageURL is nil")
                                    }
                                    
                                    // 投稿者のプロフィール画像を取得
                                    var userImageUIImage = UIImage(systemName: "person")
                                    getUserImageFromFirestorage(userUID: documentSnapshot!.get("postUserUID") as? String ?? "GuestUID") { data in
                                        if data != nil {
                                            print("投稿者画像を読み込みました：\(data!)")
                                            userImageUIImage = UIImage(data: data!)
                                        } else {
                                            print("投稿者画像が見つかりません")
                                        }
                                        bookmarkedPostCardList.append(
                                            PostForCard(omiseName: postName,
                                                 documentId: documentSnapshot!.documentID,
                                                 created_at: postCreatedAtString,
                                                 comment: postComment,
                                                 coordinate: CLLocationCoordinate2D(latitude: postLatitude,
                                                                                    longitude: postLongitude),
                                                 created_by: documentSnapshot!.get("postUserUID") as! String?,
                                                 created_by_name: documentSnapshot!.get("postUserName") as! String?,
                                                 imageURL: documentSnapshot!.get("imageURL") as! String?,
                                                 imageUIImage: postImageUIImage,
                                                 userImageUIImage: userImageUIImage!
                                                )
                                        )
                                        // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                                        bookmarkedPostCardList = bookmarkedPostCardList.sorted(by: { (a,b) -> Bool in
                                            return a.created_at > b.created_at
                                        })
                                    }
                                }
                                isShowProgress.progressSwitch = false
                            }
                    }
                } else {
                    print("ブックマークがありません")
                    isShowProgress.progressSwitch = false
                }
            }
    }
}

struct MyPageDesignView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageDesignView(currentUser: UserData(uid: "sample", email: "sample@email.com", userName: "user name"),
                         mapSwitch: .constant(.normal), isShowLoginCheckView: .constant(false))
    }
}
