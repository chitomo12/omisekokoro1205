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
struct FeatureViewDesign: View {
    @EnvironmentObject var isShowProgress: ShowProgress
    
    @State var postList: [Post] = []
    
    @State var postCardList: [PostForCard] = []
    @State var isShowingProgressView = false
    
    var body: some View {
//        let bounds = UIScreen.main.bounds
//        let screenWidth = bounds.width
        
//        ZStack(alignment: .bottom) {
            ScrollView{
                Button(action: {
                    postCardList = [] // 初期化
                    getPostListFromAll()
                }) {
                    Text("コメント取得")
                }
                .padding(.top,50)
                
                VStack {
                    ForEach(0..<postCardList.count, id: \.self) { count in
                        // 投稿をリスト化して表示
//                        PostCardView(post: $postCardList[count])
                        PostCardViewTwo(post: $postCardList[count])
                    }
                }
                .onAppear(){
                    if postCardList.count >= 1 {
                        print("投稿一覧は読み込み済みです")
                    } else {
                        // Loadingを表示
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            getPostListFromAll()
                        }
                        isShowingProgressView = true
                        isShowProgress.progressSwitch = true
                    }
                }
            }
            .ignoresSafeArea()
//        }
    }
    
    // 全投稿から最新10件を取得する
    public func getPostListFromAll(){
        // リストを初期化
        postList.removeAll()
        
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
            .limit(to: 10)
            .getDocuments() { (querySnapshot, error) in
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
//                    if let tempImageURL: String = document.get("imageURL") as! String? {
//                        print("post.imageURL: \(tempImageURL)")
//                        // オプショナルバインディング
//                        if let tempImageURLURL = URL(string: tempImageURL){
//                            print("tempImageDataURLURL: \(tempImageURLURL)")
//                            if let tempImageData = try? Data(contentsOf: tempImageURLURL) {
//                                postImageUIImage = UIImage(data: tempImageData)!
//                            }
//                        } else {
//                            print("tempImageDataURLURL is nil")
//                        }
//                    } else {
//                        print("post.imageURL is nil")
//                    }
                    // 投稿者のプロフィール画像を取得
                    var userImageUIImage = UIImage(systemName: "person")
//                    getUserImageFromFirestorage(userUID: document.get("postUserUID") as! String) { data in
//                        if data != nil {
//                            print("投稿者画像を読み込みました：\(data!)")
//                            userImageUIImage = UIImage(data: data!)
//                        } else {
//                            print("投稿者画像が見つかりません")
//                        }
                        postCardList.append(
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
                        print("ドキュメントを追加しました")
                        // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                        postCardList = postCardList.sorted(by: { (a,b) -> Bool in
                            return a.created_at > b.created_at
                        })
//                    }
                }
                if error != nil {
                    print("error: \(String(describing: error))")
                }
                
                isShowingProgressView = false
                isShowProgress.progressSwitch = false
            }
    } // getPostListFromAllここまで
}

struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureViewDesign()
    }
}
