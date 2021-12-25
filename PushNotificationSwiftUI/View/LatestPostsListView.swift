//
//  SearchDesign.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit

// 最新の投稿リストを表示するビュー
struct LatestPostsListView: View {
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var isShowPostDetailPopover: IsShowPostDetailPopover
    
    @ObservedObject var latestPosts = PostData()
    
    @State var postList: [Post] = []
    
    @State var postCardList: [PostForCard] = []
    
    // 投稿詳細ポップオーバー表示用のブーリアン（trueでポップオーバーが表示される）
    @State var isShowingDetailPopover: Bool = false
    // 投稿詳細コンテンツ表示用のブーリアン
    @State var isShowingDetailContent: Bool = false
    
    @State var lastAddedPostTimestamp: Timestamp = Timestamp(date: Date())
    
    var body: some View {
        ScrollView{
            Button(action: {
                postCardList = [] // 初期化
                latestPosts.getTenPostsFromAll(completion: { value, timestamp in
                    postCardList.append(value)
                    lastAddedPostTimestamp = timestamp
                    // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                    postCardList = postCardList.sorted(by: { (a,b) -> Bool in
                        isShowProgress.progressSwitch = false
                        return a.created_at > b.created_at
                    })
                })
            }) {
                Text("コメント取得")
            }
            .padding(.top, 50)
            
            VStack {
                ForEach(0..<postCardList.count, id: \.self) { count in
                    // 投稿をリスト化して表示
                    PostCardViewTwo(post: $postCardList[count])
                }
                Button(action: {
                    print("さらに読み込みます")
//                    getTenMorePostsFromAll()
                    latestPosts.getTenMorePosts(lastAddedPostTimestamp: lastAddedPostTimestamp, completion: { value, timestamp in
                        postCardList.append(value)
                        lastAddedPostTimestamp = timestamp
                        // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                        postCardList = postCardList.sorted(by: { (a,b) -> Bool in
                            return a.created_at > b.created_at
                        })
                    })
                }) {
                    Text("さらに読み込む").padding(EdgeInsets(top: 30, leading: 0, bottom: 100, trailing: 0))
                }
            }
            .onAppear(){
                if postCardList.count >= 1 {
                    print("投稿一覧は読み込み済みです")
                } else {
                    // Loadingを表示
                    isShowProgress.progressSwitch = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        getPostListFromAll()
                        latestPosts.getTenPostsFromAll(completion: { value, timestamp in
                            postCardList.append(value)
                            lastAddedPostTimestamp = timestamp
                            // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                            postCardList = postCardList.sorted(by: { (a,b) -> Bool in
                                isShowProgress.progressSwitch = false
                                return a.created_at > b.created_at
                            })
                        })
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
//    // Firestoreのセッティング
//    var db: Firestore!
//    let settings = FirestoreSettings()
//
//    let formatter = DateFormatter()
//    @State var lastAddedPostTimestamp: Timestamp = Timestamp(date: Date())
//
//    init(){
//        Firestore.firestore().settings = settings
//        db = Firestore.firestore()
//        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
//    }
//
//    // 全投稿から最新10件を取得する
//    public func getPostListFromAll(){
//        // リストを初期化
//        postList.removeAll()
//        isShowProgress.progressSwitch = true
//
//        db.collection("locationCollection")
//            .document("locationDocument")
//            .collection("subLocCollection")
//            .order(by: "created_at", descending: true)  // 日付降順で取得
//            .limit(to: 10)
//            .getDocuments() { (querySnapshot, error) in
//                addPostsToPostCardList(querySnapshot: querySnapshot, error: error)
//            }
//    } // getPostListFromAllここまで
//
//    // 全投稿からさらに追加10件を取得する
//    public func getTenMorePostsFromAll(){
//        db.collection("locationCollection")
//            .document("locationDocument")
//            .collection("subLocCollection")
//            .order(by: "created_at", descending: true)  // 日付降順で取得
//            .whereField("created_at", isLessThan: lastAddedPostTimestamp)
//            .limit(to: 8)
//            .getDocuments() { (querySnapshot, error) in
//                addPostsToPostCardList(querySnapshot: querySnapshot, error: error)
//            }
//    } // getPostListFromAllここまで
//
//    // querySnapshotからカード表示用structに整形する
//    private func addPostsToPostCardList(querySnapshot: QuerySnapshot?, error: Error?) {
//        for document in querySnapshot!.documents {
//            let postName = String(describing: document.get("name")! )
//            let postCreatedAt = document.get("created_at") as! Timestamp
//            lastAddedPostTimestamp = postCreatedAt
//            let postCreatedAtDate = postCreatedAt.dateValue()
//            let postCreatedAtString = formatter.string(from: postCreatedAtDate)
//            let postComment = String(describing: document.get("comment")! )
//            let postLatitude = document.get("latitude") as! Double
//            let postLongitude = document.get("longitude") as! Double
//
//            // カード用の構造体postCardListにデータを格納
//            //   Postのリストとの違いはUIImageのプロパティがあること。
//            var postImageUIImage: UIImage? = UIImage(named: "SampleImage")
//
//            // オプショナルバインディング
//            if let tempImageURL = URL(string: document.get("imageURL") as! String){
//                print("次のURLから画像を読み込みます: \(tempImageURL)")
//                do {
//                    let tempImageData = try Data(contentsOf: tempImageURL)
//                    postImageUIImage = UIImage(data: tempImageData)
//                    print("画像を読み込みました")
//                } catch {
//                    print("画像の読み込みに失敗")
//                }
//            } else {
//                print("tempImageDataURLURL is nil")
//            }
//
//            // 投稿者のプロフィール画像を取得
//            var userImageUIImage = UIImage(named: "SampleImage")
//            getUserImageFromFirestorage(userUID: document.get("postUserUID") as! String) { data in
//                if data != nil {
//                    print("投稿者画像を読み込みました：\(data!)")
//                    userImageUIImage = UIImage(data: data!)
//                } else {
//                    print("投稿者画像が見つかりません")
//                }
//                postCardList.append(
//                    PostForCard(omiseName: postName,
//                         documentId: document.documentID,
//                         created_at: postCreatedAtString,
//                         comment: postComment,
//                         coordinate: CLLocationCoordinate2D(latitude: postLatitude,
//                                                            longitude: postLongitude),
//                         created_by: document.get("postUserUID") as! String?,
//                         created_by_name: document.get("postUserName") as! String?,
//                         imageURL: document.get("imageURL") as! String?,
//                         imageUIImage: postImageUIImage,
//                         userImageUIImage: userImageUIImage!
//                        )
//                )
//
////                latestPosts.postForCardList.append(
////                    PostForCard(omiseName: postName,
////                         documentId: document.documentID,
////                         created_at: postCreatedAtString,
////                         comment: postComment,
////                         coordinate: CLLocationCoordinate2D(latitude: postLatitude,
////                                                            longitude: postLongitude),
////                         created_by: document.get("postUserUID") as! String?,
////                         created_by_name: document.get("postUserName") as! String?,
////                         imageURL: document.get("imageURL") as! String?,
////                         imageUIImage: postImageUIImage,
////                         userImageUIImage: userImageUIImage!
////                        )
////                )
////                print("latestPosts.postForCardList.count: \(latestPosts.postForCardList.count)")
//
//                print("ドキュメントを追加しました: \(postComment)")
//                // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
//                postCardList = postCardList.sorted(by: { (a,b) -> Bool in
//                    return a.created_at > b.created_at
//                })
//            }
//        }
//        if error != nil {
//            print("error: \(String(describing: error))")
//        }
//        isShowProgress.progressSwitch = false
//    }
}

struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        LatestPostsListView()
    }
}
