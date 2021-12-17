//
//  AnimationTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/13.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct TabWithAnimationView: View {
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var environmentFcmToken: FcmToken
    @EnvironmentObject var isShowPostDetailPopover: IsShowPostDetailPopover
    
    @ObservedObject var omiseDataList = OmiseData()
    @ObservedObject var postData = PostData()
    @ObservedObject var currentUser: UserData
    
    // ログイン状態の管理
    @State var loggedInUserName: String = ""
    @State var loggedInUserEmail: String = ""
    
    @State var selectedTag = 1
    
    @State var latitude: Double = 0.0
    @State var longitude: Double = 0.0
    @State var searchedLocationName: String = "default"
    @State var searchedAddress: String = ""
    @State var mapSwitch: MapSwitch = .initialized
    
    // 円の半径
    @State var circleRadius: CGFloat = 30
    @State var circleDefaultLocX: CGFloat = .zero
    @State private var circleOffsetX: CGFloat = .zero
    @State var circleColorNow = Color(red: 1, green: 0.5, blue: 0.5)
    @State var springAnimation: Animation = .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    @State var colorOfSelectedIcon = Color(red: 1, green: 0.5, blue: 0.5)
    @State var colorOfNonSelectedIcon = Color(red:1, green:0, blue:0)
    @State var colorOfIconOne = Color(red: 1, green: 0.5, blue: 0.5)
        
    @State var iconsLocX: [CGFloat] = [0,0,0,0,0]
    @State var circleColorOne = Color("ColorOne")
    @State var circleColorTwo = Color(red: 217/255, green: 83/255, blue: 79/255)
    @State var circleColorThree = Color(red: 150/255, green: 206/255, blue: 180/255)
    @State var circleColorFour = Color(red: 255/255, green: 173/255, blue: 96/255)
    @State var circleColors: [Color] = [.white,
                                        Color("ColorOne"),
                                        Color("ColorTwo"),
                                        Color("ColorThree"),
                                        Color("ColorFour")]
    @State var IconColors: [Color] = [.white, .white, Color("ColorOne"), Color("ColorOne"), Color("ColorOne")]
    @State var linearGradientNow = LinearGradient(gradient: Gradient(colors: [.green, .blue]),
                                                 startPoint: .top,
                                                 endPoint: .bottom)
    @State var linearGradientA = LinearGradient(gradient: Gradient(colors: [.red, .green]),
                                                 startPoint: .top,
                                                endPoint: .bottom)
    @State var linearGradientB = LinearGradient(gradient: Gradient(colors: [.blue, .red]),
                                                 startPoint: .top,
                                                endPoint: .bottom)
    
    // アイコンのアニメーション
    @State var slowSpringAnimation: Animation = .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)
    @State var rotationOne = false
    @State var rotationTwo = false
    @State var rotationThree = false
    @State var rotationFour = false
    
    @State var isShowLoginView = false
    @State var isShowLoginCheckView = false
    
    // 投稿詳細画面用のプロパティ
    @State var isShowingDetailContent = false
    @State var selectedPostDocumentUID: String = ""
    @State var isShowingAlert = false
    
    // カード表示用のリスト
    @State var notificationCardList: [NotificationCardData] = []
    
    init(currentUser: UserData){
        self.currentUser = currentUser
//        self.environmentFcmToken.fcmTokenString = appDelegate.fcmToken
    }
    
    var body: some View {
        ZStack{
            VStack{
                // コンテンツ表示コーナー
                TabView(selection: $selectedTag) {
                    MapAndSearch(currentUser: currentUser,
                                 searchedLocationName: $searchedLocationName,
                                 searchedAddress: $searchedAddress,
                                 mapSwitch: $mapSwitch)
                        .tabItem{}.tag(1)
                    
                    FeatureViewDesign()
                        .tabItem{}.tag(2)
                    
                    MyPageDesignView(currentUser: currentUser, notificationCardList: $notificationCardList, mapSwitch: $mapSwitch, isShowLoginCheckView: $isShowLoginCheckView)
                        .tabItem{}.tag(3)
                    
                    NotificationListView(mapSwitch: $mapSwitch, notificationCardList: $notificationCardList)
                        .tabItem{}.tag(4)
                }
                .tabViewStyle(PageTabViewStyle())
                .animation(.default, value: selectedTag)
                .edgesIgnoringSafeArea(.top)
                .onAppear {
                    // プッシュ通知用トークンを取得し、環境変数に格納する。
                    Messaging.messaging().token { token, error in
                      if let error = error {
                        print("Error fetching FCM registration token: \(error)")
                      } else if let token = token {
                        print("FCM registration token: \(token)")
//                        self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
                          environmentFcmToken.fcmTokenString = token
                      }
                    }
                }
                
                // タブ選択コーナー
                ZStack (alignment: .center){
                    // アイコン間を動く円
                    GeometryReader { geo in
                        
                        Circle()
                            .frame(width: circleRadius * 2, height: circleRadius * 2)
                            .shadow(color: circleColors[selectedTag], radius:2,x:0,y:3)
                            .offset(x: circleOffsetX, y: 30-circleRadius)
                            .foregroundColor(circleColors[selectedTag])
                            .onAppear{
                                // NavigationLinkの描画ラグ対策のため、時差を置いて値を設定する
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    if circleDefaultLocX == .zero {
                                        circleDefaultLocX = geo.frame(in: .global).minX
                                        print("circleDefaultLocX: \(circleDefaultLocX)")
                                    }
                                }
                            }
                        
                    }
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    
                    HStack {
                        GeometryReader { geo in
                            tabButtonIconViewModel(imageName: "globe.asia.australia", iconName: "Omise")
                                .rotationEffect(Angle.degrees(rotationOne ? 0 : 360))
                                .foregroundColor(IconColors[1])
                                .onAppear {
                                    // 初回表示時のみ丸の位置を初期化
                                    if circleOffsetX == .zero {
                                        circleOffsetX = geo.frame(in: .local).midX - circleRadius
    //                                    circleDefaultLocX = circleOffsetX
                                    }
                                }
                                .onChange(of: selectedTag) { value in
                                    // 最初にselectedTagが変わるタイミングでビューの座標を取得
                                    iconsLocX[1] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    iconsLocX[1] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                    moveCircle(selectedIcon: 1)
                                    withAnimation(slowSpringAnimation){
                                        rotationOne.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        GeometryReader{ geo in
                            tabButtonIconViewModel(imageName: "magnifyingglass", iconName: "Search")
                                .foregroundColor(IconColors[2])
                                .rotationEffect(Angle.degrees(rotationTwo ? 0 : 360))
                                .onChange(of: selectedTag) { value in
                                    // 最初にselectedTagが変わるタイミングでビューの座標を取得
                                    iconsLocX[2] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    moveCircle(selectedIcon: 2)
                                    withAnimation(slowSpringAnimation){
                                        rotationTwo.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        GeometryReader{ geo in
                            tabButtonIconViewModel(imageName: "person", iconName: "My Page")
                                .foregroundColor(IconColors[3])
                                .rotationEffect(Angle.degrees(rotationThree ? 0 : 360))
                                .onChange(of: selectedTag) { value in
                                    iconsLocX[3] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    moveCircle(selectedIcon: 3)
                                    withAnimation(slowSpringAnimation){
                                        rotationThree.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        GeometryReader{ geo in
                            tabButtonIconViewModel(imageName: "envelope", iconName: "Info")
                                .foregroundColor(IconColors[4])
                                .rotationEffect(Angle.degrees(rotationFour ? 0 : 360))
                                .onChange(of: selectedTag) { value in
                                    iconsLocX[4] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    moveCircle(selectedIcon: 4)
                                    withAnimation(slowSpringAnimation){
                                        rotationFour.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } // HStackここまで
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .onChange(of: selectedTag){ newValue in
                    moveCircle(selectedIcon: newValue)
                }
                .padding(.bottom)
                // ZStackここまで
            }
            .padding(.bottom)

            .background(LinearGradient(gradient: Gradient(colors: [.white, circleColorNow]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .opacity(0.1))
            .edgesIgnoringSafeArea(.bottom)
            .onAppear{
                if let user = Auth.auth().currentUser {
                    print("user.uid: \(user.uid)")
                    print("user.email: \(user.email ?? "")")
                    loggedInUserName = user.email ?? ""
                    loggedInUserEmail = user.email ?? ""
                    print("self!.loggedInUserName: \(loggedInUserName)")
                }
            }
            
            // ロード中表示
            if isShowProgress.progressSwitch {
                ProgressView("Loading")
                    .frame(width:100, height:120, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(10)
                    .opacity(0.95)
            }
        }
        
        .popover(isPresented: $isShowLoginCheckView) {
            AuthTest(isShowLoginCheckView: $isShowLoginCheckView)
        }
        
        .popover(isPresented: $isShowPostDetailPopover.showSwitch) {
//            Text("isShowPostDetailPopover")
            
//            PostDetailView(selectedPost: $selectedPost,
//                           isShowingDetailContent: $isShowingDetailContent,
//                           selectedPostImageData: $selectedPostImageData,
//                           selectedPostImageUIImage: $selectedPostImageUIImage,
//                           selectedPostUserImageUIImage: $selectedPostUserImageUIImage,
//                           isFavoriteAddedToSelectedPost: $isFavoriteAddedToSelectedPost,
//                           isBookmarkAddedToSelectedPost: $isBookmarkAddedToSelectedPost,
//                           )
            
            ZStack {
                // 背景
                Image("BackgroundOne")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .scaledToFill()
                    .clipped()
                    .opacity(0.8)
                
                VStack {
                    PostDetailViewTwo()
                    
                    // ログイン中のユーザーUIDと一致する場合のみ表示
                    if isShowPostDetailPopover.selectedPostCreateUserUID == currentUser.uid {
                        // 削除ボタン
                        Button(action:{
                            isShowingAlert = true
                            print("削除します")
                        }){
                            Text("投稿を削除")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .alert(isPresented: $isShowingAlert){
                            Alert(title: Text("本当に削除しますか？"),
                                  message: Text("元に戻すことはできません"),
                                  primaryButton: .cancel(Text("キャンセル")),
                                  secondaryButton: .destructive(Text("削除"), action: {
                                // 削除ボタンが押されたら投稿削除を実行
                                deleteComment(targetDocumentID: isShowPostDetailPopover.selectedPostDocumentUID)
                                // 削除後、変数を初期化しポップオーバーを閉じる
                                isShowPostDetailPopover.selectedPostDocumentUID = ""
                                isShowPostDetailPopover.showSwitch = false
    //                            map.removeAnnotation(selectedPostAnnotation.annotation!)
                            }))
                        }
                    }
                    
                } // popover内のVStackここまで
            }.ignoresSafeArea() //ZStackここまで
        }
    }
    
    // Circleを動かすためのビュー固有関数
    public func moveCircle(selectedIcon: Int){
        selectedTag = selectedIcon
        withAnimation(springAnimation){
            circleOffsetX = iconsLocX[selectedIcon]
            circleColorNow = circleColors[selectedIcon]
        }
        (0..<IconColors.count).forEach{ IconColors[$0] = circleColorNow }
        IconColors[selectedIcon] = .white
    }
    
    // ポスト詳細ポップオーバー表示用のメソッド
    public func ShowPostDetail(postUID: String) {
        // TabWithAnimationViewにポップオーバー表示の処理を要求
        // コンテンツはローディング表示
        isShowingDetailContent = false
        isShowPostDetailPopover.showContent = false
        // ポップオーバーを表示（コンテンツはローディング表示）
//        self.parent.isShowingDetailPopover = true
        isShowPostDetailPopover.showSwitch = true
        
        // documentIDからポストの詳細を取得し、詳細画面を生成する
        let documentKeyId = postUID
        let postData = PostData()
//        var selectedPost = PostForCard()
        postData.getPostDetail(documentKeyID: documentKeyId, completion: { onePost in
//            // 削除するパターン分岐に備え、アノテーションを渡しておく
//            self.parent.selectedPostAnnotation = annotationView
//            // ドキュメントID自体はドキュメント内に保持されないので別に変数を用意して格納する
//            self.parent.selectedPostDocumentID = onePost.documentId
            // 投稿者名、コメント文などが格納されたドキュメント情報を渡す
//            selectedPost = onePost
            
            
//            self.envPostForCardData.documentId = documentKeyId
//            self.envPostForCardData.created_at = onePost.created_at
//
//            // お店画像の読み込み（登録がない場合はダミー画像を表示）
//            let postImageURL: URL? = URL(string: onePost.imageURL ?? "")
//            if postImageURL != nil{
//                print("①postImageURL: \(String(describing:postImageURL))を読み込みます")
//                do{
//                    self.selectedPostImageData = try Data(contentsOf: postImageURL!)
//                } catch {
//                    print("error")
//                }
//            } else {
//                print("②postImageURLがnilです")
//                self.parent.selectedPostImageData = nil
//                self.parent.selectedPostImageUIImage = nil
//            }
//
//            if self.parent.selectedPostImageData != nil{
//                print("③")
//                self.parent.selectedPostImageUIImage = UIImage(data: self.parent.selectedPostImageData!)!
//            } else {
//                print("④Error")
//                self.parent.selectedPostImageUIImage = nil
//            }
//
//            // ファボ、ブックマークの判定
//            print("check start")
//            CheckFavorite(postID: onePost.documentId, currentUserID: self.parent.environmentCurrentUser.uid, completion: { resultBool, foundedFavID in
//                self.parent.isFavoriteAddedToSelectedPost = resultBool
//                self.parent.FavoriteID = foundedFavID
//
//                CheckBookmark(postID: onePost.documentId, currentUserID: self.parent.environmentCurrentUser.uid, completion: { resultBool, foundedBookmarkID in
//                    self.parent.isBookmarkAddedToSelectedPost = resultBool
//                    self.parent.BookmarkID = foundedBookmarkID
//
//                    getUserImageFromFirestorage(userUID: onePost.created_by ?? "GuestUID") { data in
//                        if data != nil {
//                            print("投稿者プロフィール画像を読み込みます：\(data!)")
//                            self.parent.selectedPostUserImageUIImage = UIImage(data: data!)!
//                        } else {
//                            print("投稿者プロフィール画像が見つかりません")
//                            self.parent.selectedPostUserImageUIImage = UIImage(named: "SampleImage")!
//                        }
//
//                        // 投稿詳細内容を表示
//                        self.parent.isShowingDetailContent = true
//                    }
//                })
//            })
            
        })
//        // 同じアノテーションを連続タップすると反応がなくなる不具合：
//        // 　- タップするとアノテーションが選択状態になるため、選択状態を解除してあげる。
//        for annotation in mapView.selectedAnnotations {
//            mapView.deselectAnnotation(annotation, animated: false)
//        }
    }
}

struct tabButtonIconViewModel: View{
    var imageName: String
    var iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
            .frame(width: 20, height: 20)
            Text(iconName)
                .font(.caption2)
                .fontWeight(.bold)
        }
    }
}

struct AnimationTest_Previews: PreviewProvider {
    static var previews: some View {
        TabWithAnimationView(currentUser: UserData(uid: "sample", email: "sample@email.com", userName: "sampleName"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
    }
}
