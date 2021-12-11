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
    @EnvironmentObject var isShowPostDetailPopover: IsShowPostDetailPopover
    
    @State var postList: [Post] = []
    
    @State var postCardList: [PostForCard] = []
    @State var isShowingProgressView = false
    
    // 投稿詳細ポップオーバー表示用のブーリアン（trueでポップオーバーが表示される）
    @State var isShowingDetailPopover: Bool = false
    // 投稿詳細コンテンツ表示用のブーリアン
    @State var isShowingDetailContent: Bool = false 
    
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
                    Button(action: {
                        print("さらに読み込みます")
                    }) {
                        Text("さらに読み込む").padding()
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
                    
                    // カード用の構造体postCardListにデータを格納
                    //   Postのリストとの違いはUIImageのプロパティがあること。
                    var postImageUIImage: UIImage? = UIImage(named: "SampleImage")
//                    // imageURLのnilチェック
//                    if let tempImageURL: String = document.get("imageURL") as! String? {
//                        print("post.imageURL: \(tempImageURL)")
                    
                    // オプショナルバインディング
                    if let tempImageURL = URL(string: document.get("imageURL") as! String){
                        print("次のURLから画像を読み込みます: \(tempImageURL)")
                        do {
                            let tempImageData = try Data(contentsOf: tempImageURL)
                            postImageUIImage = UIImage(data: tempImageData)
//                            if let tempImageData = try Data(contentsOf: tempImageURL) {
//                                postImageUIImage = UIImage(data: tempImageData)!
//                            }
                            print("画像を読み込みました")
                        } catch {
                            print("画像の読み込みに失敗")
                        }
                    } else {
                        print("tempImageDataURLURL is nil")
                    }
                    
//                    } else {
//                        print("お店画像URLがないため読み込みません")
//                    }
                    
                    // 投稿者のプロフィール画像を取得
                    var userImageUIImage = UIImage(systemName: "person")
                    getUserImageFromFirestorage(userUID: document.get("postUserUID") as! String) { data in
                        if data != nil {
                            print("投稿者画像を読み込みました：\(data!)")
                            userImageUIImage = UIImage(data: data!)
                        } else {
                            print("投稿者画像が見つかりません")
                        }
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
                    }
                }
                if error != nil {
                    print("error: \(String(describing: error))")
                }
                
                isShowingProgressView = false
                isShowProgress.progressSwitch = false
            }
    } // getPostListFromAllここまで
    
//    // カードが選択されたら呼ぶメソッド
//    func mapView(_ mapView: MKMapView, didSelect annotationView: MKAnnotationView) {
//        print("カードがタップされました: \(post.documentId)")
//        // ポップオーバーを表示（コンテンツはローディング表示）
//        isShowingDetailPopover = true
//        isShowingDetailContent = false
//
//        // アノテーションが保持するdocumentIDからポストの詳細を取得し、詳細画面を表示する
//        let documentKeyId = annotationView.annotation!.title!!
//        let postData = PostData()
//        postData.getPostDetail(documentKeyID: documentKeyId, completion: { onePost in
//            // 削除するパターン分岐に備え、アノテーションを渡しておく
//            self.parent.selectedPostAnnotation = annotationView
//            // ドキュメントID自体はドキュメント内に保持されないので別に変数を用意して格納する
//            self.parent.selectedPostDocumentID = onePost.documentId
//            // 投稿者名、コメント文などが格納されたドキュメント情報を渡す
//            self.parent.selectedPost = onePost
//
//            // お店画像の読み込み（登録がない場合はダミー画像を表示）
//            let postImageURL: URL? = URL(string: onePost.imageURL ?? "")
//            if postImageURL != nil{
//                print("①postImageURL: \(String(describing:postImageURL))を読み込みます")
//                do{
//                    self.parent.selectedPostImageData = try Data(contentsOf: postImageURL!)
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
//
//        })
//        // 同じアノテーションを連続タップすると反応がなくなる不具合：
//        // 　- タップするとアノテーションが選択状態になるため、選択状態を解除してあげる。
//        for annotation in mapView.selectedAnnotations {
//            mapView.deselectAnnotation(annotation, animated: false)
//        }
//    }
//    // アノテーションが選択されたら呼ばれるメソッドここまで
}

struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureViewDesign()
    }
}
