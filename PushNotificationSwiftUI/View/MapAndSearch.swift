//
//  MainMapView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/10/30.
//

import SwiftUI
import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth

struct MapAndSearch: View {
    //    // 位置追従
    //    @ObservedObject var manager = LocationManager()
    //    @State var trackingMode = MapUserTrackingMode.follow
    //
    //    var body: some View {
    //        Map(coordinateRegion: $manager.region,
    //            showsUserLocation: true,
    //            userTrackingMode: $trackingMode)
    //            .edgesIgnoringSafeArea(.bottom)
    //    }
    @EnvironmentObject var environmentCurrentUserData: UserData
    
    @ObservedObject var omiseDataList = OmiseData()
    @ObservedObject var currentUser: UserData
    
    // 選択中の緯度経度
    @Binding var searchedLocationName: String
    @Binding var searchedAddress: String
    @Binding var mapSwitch: MapSwitch
        
    @State var isPopover: Bool = false
    @State var isShowingAlert: Bool = false // 詳細画面にて、削除確認画面表示用のBool
    @State var commentText: String = ""
    
    // 座標、表示範囲を一時保存用の変数
    @State var tempCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State var tempSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @State var tempMapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @State var map = MKMapView() // タブ移動時にMapが初期化されることを防ぐため、上位のビューで宣言しておく
    
    // 詳細画面表示用のBoolean（trueで表示）
    @State var isShowingDetail: Bool = false
    @State var isShowingDetailContent: Bool = false
    
    // マップで選択したアノテーションの情報を格納
    @State var selectedPostDocumentID: String? = ""  // Firestorage上のDocumentID
    @State var selectedPost = Post(omiseName: "", documentId: "", created_at: "", comment: "", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), created_by: "", created_by_name: "", imageURL: "")
    @State private var showingAlert = false
    @State var selectedPostAnnotation = MKAnnotationView()
    
    // コメント投稿画面にて選択したお店情報を格納する変数
    @State var searchedAndSelectedOmiseLatitude: Double = 0.0
    @State var searchedAndSelectedOmiseLongitude: Double = 0.0
    @State var searchedAndSelectedOmiseImageURL: String? = ""
    @State var temporalSelectedTag: Int = 1
    
    // コメントボタンのドラッグアニメーション用変数
    @State var drag: CGSize = .zero
    
    @State var selectedPostImageData: Data? = nil
    @State var selectedPostImageUIImage: UIImage? = nil
    @State var selectedPostUserImageUIImage: UIImage = UIImage(named:"SampleImage")!
    
    // 「ロード中」表示のBoolean
    @State var isShowingProgressView: Bool = true
    
    // 詳細画面にて、お気に入りとブックマーク登録済みか否かを指し示す変数
    @State var isFavoriteAddedToSelectedPost: Bool = false
    @State var FavoriteID: String = ""
    @State var isBookmarkAddedToSelectedPost: Bool = false
    @State var BookmarkID: String = ""
    
    @State var isShowLoginCheckView = true
    @State var isShowLoginView = false
    
    var viewController = ViewController()
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        
        VStack {
            Image("omisekokoro_bar")
                .resizable()
                .scaledToFit()
                .frame(height:25)
            
            ZStack(alignment: .center) {
                ZStack(alignment: .bottomTrailing) {
                    MapView(searchedLocationName: $searchedLocationName,
                            searchedAddress: $searchedAddress,
                            mapSwitch: $mapSwitch,
                            map: $map,
                            isShowingDetailPopover: $isShowingDetail,
                            isShowingDetailContent: $isShowingDetailContent,
                            selectedPostDocumentID: $selectedPostDocumentID,
                            selectedPostAnnotation: $selectedPostAnnotation,
                            selectedPost: $selectedPost,
                            selectedPostImageData: $selectedPostImageData,
                            selectedPostImageUIImage: $selectedPostImageUIImage,
                            selectedPostUserImageUIImage: $selectedPostUserImageUIImage,
                            isFavoriteAddedToSelectedPost: $isFavoriteAddedToSelectedPost,
                            FavoriteID: $FavoriteID,
                            isBookmarkAddedToSelectedPost: $isBookmarkAddedToSelectedPost,
                            BookmarkID: $BookmarkID,
                            isLoadingAnnotationViews: $isShowingProgressView)
                        .edgesIgnoringSafeArea(.top)
                    
                    // 投稿画面表示ボタン
                    Button(action: {
                        print("Buttonが押されました")
                        isPopover = true
                    }) {
                        ZStack(){
                            Circle()
                                .frame(width: 60, height: 60, alignment: .center)
                                .foregroundColor(.white)
                                .opacity(0.95)
                            Image(systemName: "plus.bubble.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .offset(x: 0.5, y: 1)
                                .foregroundColor(.yellow)
                        }
                        .offset(drag)
                        .gesture(
                            DragGesture()
                                .onChanged{ value in
                                    withAnimation(Animation.spring(response: 0, dampingFraction: 1, blendDuration: 0.2)){
                                        self.drag = value.translation
                                    }
                                }
                                .onEnded{ _ in
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.5)) {
                                        self.drag = .zero
                                    }
                                }
                        )
                    }.padding(25)
                    
                        // 投稿用ポップオーバー
                        .popover(isPresented: $isPopover) {
                            OmiseSearchAndPostView(omiseDataList: omiseDataList,
                                                   currentUser: currentUser,
                                            selectedTag: $temporalSelectedTag,
                                            searchedAndSelectedOmiseLatitude: $searchedAndSelectedOmiseLatitude,
                                            searchedAndSelectedOmiseLongitude: $searchedAndSelectedOmiseLongitude,
                                            searchedAndSelectedOmiseName: $searchedLocationName,
                                            searchedAndSelectedOmiseAddress: $searchedAddress,
                                            searchedAndSelectedOmiseImageURL: $searchedAndSelectedOmiseImageURL,
                                            mapSwitch: $mapSwitch,
                                            isPopover: $isPopover)
                        } // .popoverここまで
                    
                        // アノテーション選択時の詳細表示用ポップオーバー
                        .popover(isPresented: $isShowingDetail) {
                            ZStack {
                                // 背景
                                Image("BackgroundOne")
                                    .resizable()
                                    .frame(width: bounds.width, height: bounds.height)
                                    .scaledToFill()
                                    .clipped()
                                    .opacity(0.8)
                                
                                VStack {
                                    PostDetailView(selectedPost: $selectedPost,
                                                   isShowingDetailContent: $isShowingDetailContent,
                                                   selectedPostImageData: $selectedPostImageData,
                                                   selectedPostImageUIImage: $selectedPostImageUIImage,
                                                   selectedPostUserImageUIImage: $selectedPostUserImageUIImage,
                                                   isFavoriteAddedToSelectedPost: $isFavoriteAddedToSelectedPost,
                                                   isBookmarkAddedToSelectedPost: $isBookmarkAddedToSelectedPost,
                                                   favDocumentID: $FavoriteID,
                                                   bookmarkDocumentID: $BookmarkID)
                                    
                                    // 削除ボタン
                                    Button(action:{
                                        isShowingAlert = true
                                        print("削除します")
                                    }){
                                        Text("削除")
                                    }
                                    .foregroundColor(.red)
                                    .padding()
                                    .alert(isPresented: $isShowingAlert){
                                        Alert(title: Text("本当に削除しますか？"),
                                              message: Text("元に戻すことはできません"),
                                              primaryButton: .cancel(Text("キャンセル")),
                                              secondaryButton: .destructive(Text("削除"), action: {
                                            // 削除ボタンが押されたらコメント削除を実行
                                            deleteComment(targetDocumentID: selectedPostDocumentID!)
                                            // 削除後、変数を初期化しポップオーバーを閉じる
                                            selectedPostDocumentID = ""
                                            isShowingDetail = false
                                            map.removeAnnotation(selectedPostAnnotation.annotation!)
                                        }))
                                    }
                                } // popover内のVStackここまで
                            }.ignoresSafeArea() //ZStackここまで
                        } // .popover(isPresented: $isShowingDetail)ここまで
                    
                        // 起動時に表示し、ログイン状態をチェックするポップオーバー
                        .popover(isPresented: $isShowLoginCheckView){
                            if isShowLoginView == false {
                                VStack{
                                    Image("omisekokoroLogo")
                                        .resizable()
                                        .frame(width: 300, height: 300, alignment: .center)
                                        .scaledToFill()
                                    Text("🥘いらっしゃい！")
                                    ProgressView()
                                }
                                    .onAppear(perform: {
                                        print("ログイン情報を確認します")
                                        // ログイン情報を確認
                                        environmentCurrentUserData.CheckIfUserLoggedIn { isLoggedIn in
                                            if isLoggedIn == true {
                                                print("\(environmentCurrentUserData.userName!)さんこんにちは！")
                                                
//                                                // プッシュ通知の確認
//                                                UNUserNotificationCenter.current()
//                                                    .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//                                                        if granted == true {
//                                                            print("プッシュ通知が承認されました")
//                                                            // Push通知を有効化します
//                                                            // application.registerForRemoteNotifications()
//
//                                                      } else {
//                                                            print("プッシュ通知が拒否されました")
//                                                        }
//
//                                                }
                                                
                                                isShowLoginCheckView = false
                                            } else {
                                                print("ログイン画面を表示します")
                                                isShowLoginView = true
                                            }
                                        }
                                    })
                            }else{
                                AuthTest(isShowLoginCheckView: $isShowLoginCheckView)
                            }
                        }.opacity(0.95)
                } // ZStack(alignment: .bottomTrailing)ここまで
                
                // ロード中表示のビュー（コメント読み込み後に非表示）
                if isShowingProgressView{
                    ProgressView("Loading")
                        .padding(.all)
                        .frame(width: 100, height: 100)
                        .background(Color.white)
                        .cornerRadius(10)
                        .opacity(isShowingProgressView ? 1 : 0)
                }
            } // ZStack(alignment: .center)ここまで
        } // 一番外側のVStackここまで
    }
}

//struct ContentView_Previews: PreviewProvider {
//    let isShowingProgressView = false
//
//    static var previews: some View {
//        MapAndSearch(currentUser: UserData(uid: "sample", email: "sample", userName: "sample name"),
//                     searchedLocationName: .constant("default"),
//                     searchedAddress: .constant(""),
//                     mapSwitch: .constant(.normal)
//        )
//    }
//}
