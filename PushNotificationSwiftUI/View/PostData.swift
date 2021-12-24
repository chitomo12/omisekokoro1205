//
//  PostData.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/10.
//

import Foundation
import Firebase
import FirebaseFirestore
import GeoFire

// 投稿の構造体
struct Post: Identifiable{
    let id = UUID()
    let omiseName: String
    let documentId: String
    let created_at: String
    let comment: String
    let coordinate: CLLocationCoordinate2D
    let created_by: String?
    let created_by_name: String?
    let imageURL: String?
}

// カード表示用のstruct
struct PostForCard: Identifiable{
    let id = UUID()
    var omiseName: String
    var documentId: String
    var created_at: String
    let comment: String
    let coordinate: CLLocationCoordinate2D
    let created_by: String?
    let created_by_name: String?
    let imageURL: String?
    let imageUIImage: UIImage?
    let userImageUIImage: UIImage
}

// データ処理用のクラス
class PostData: ObservableObject {
    @Published var postList: [Post] = []
    
    // 日付表記のフォーマット
    let formatter = DateFormatter()
    
    // Firestoreのセッティング①
    var db: Firestore!
    let settings = FirestoreSettings()
    
    init(){
        // Firestoreのセッティング②
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    // １ドキュメントの詳細を読み込む
    // ■ Parameter
    //  - documentKeyID: 見つけたいドキュメントのID
    //  - completion: 取得後の処理を記したクロージャ
    func getPostDetail(documentKeyID: String, completion: @escaping(Post) -> Void) {
        print("\(documentKeyID)の詳細を取得します")
        // 日付表記のフォーマット
        self.formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        
        db.collection("locationCollection")
            .document("locationDocument")
            .collection("subLocCollection")
            .document(documentKeyID)
            .getDocument() { (document, error) in
                if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("Document data: \(dataDescription)")
                    } else {
                        print("\(documentKeyID)のDocumentが存在しません")
                    }
                let postName = String(describing: document!.get("name") ?? "" )
                let postCreatedAt = document!.get("created_at") as! Timestamp
                let postCreatedAtDate = postCreatedAt.dateValue()
                let postCreatedAtString = self.formatter.string(from: postCreatedAtDate)
                let postComment = String(describing: document!.get("comment") ?? "" )
                let postLatitude = document!.get("latitude") as! Double
                let postLongitude = document!.get("longitude") as! Double
                completion(
                    Post(
                        omiseName: postName,
                        documentId: document!.documentID,
                        created_at: postCreatedAtString,
                        comment: postComment,
                        coordinate: CLLocationCoordinate2D(latitude: postLatitude, longitude: postLongitude),
                        created_by: document!.get("postUserUID") as! String?,
                        created_by_name: document!.get("postUserName") as! String?,
                        imageURL: document!.get("imageURL") as! String?
                    )
                )
            }
    }
    
    // 最新の投稿１０件を読み込む
    
    // 周囲50kmの投稿を取得する
    //  第１引数 givenCenter：中心座標（CLLocationCoordinate2D）
    //  第２引数 radius：半径（Double）
    func getPostListAround(givenCenter center: CLLocationCoordinate2D, radius radiusInM: Double, completion: @escaping (Post) -> Void){

        // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
        // a separate query for each pair. There can be up to 9 pairs of bounds
        // depending on overlap, but in most cases there are 4.
        let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radiusInM)
        let queries = queryBounds.map { bound -> Query in
            print("bound.start: \(bound.startValue), bound.end: \(bound.endValue)")
            return db.collection("locationCollection")
                .document("locationDocument")
                .collection("subLocCollection")
                .order(by: "geohash")
                .order(by: "created_at",descending: false)
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
                .limit(to: 6)
        }
        
        // マッチしたドキュメント用の変数（使ってない）
//        var matchingDocs = [QueryDocumentSnapshot]()
        
        // After all callbacks have executed, matchingDocs contains the result. Note that this
        // sample does not demonstrate how to wait on all callbacks to complete.
        for query in queries {
            print(">for query in queries")
            query.getDocuments(completion: getDocumentsCompletion)
        }
        
        // Collect all the query results together into a single list
        // 全クエリの結果をリストに格納
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            print(">func getDocumentsCompletion")
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }
            
            for document in documents {
                
                // We have to filter out a few false positives due to GeoHash accuracy, but most will match
                // 読み込む範囲を距離から正確に計算し、指定したい場合。
//                let lat = document.data()["lat"] as? Double ?? 0
//                let lng = document.data()["lng"] as? Double ?? 0
//                let coordinates = CLLocation(latitude: lat, longitude: lng)
//                let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
//                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
//                if distance <= radiusInM {
//                    matchingDocs.append(document)
//                }
                
                let postName = String(describing: document.get("name")!)
                let postComment = String(describing: document.get("comment")!)
                let postCreatedAt = document.get("created_at") as! Timestamp
                let postCreatedAtString = self.formatter.string(from: postCreatedAt.dateValue())
                let postLatitude = document.get("latitude") as! Double
                let postLongitude = document.get("longitude") as! Double
                let aPost = Post(omiseName: postName,
                                 documentId: document.documentID,
                                 created_at: postCreatedAtString,
                                 comment: postComment,
                                 coordinate: CLLocationCoordinate2D(latitude: postLatitude, longitude: postLongitude),
                                 created_by: document.get("postUserUID") as! String?,
                                 created_by_name: document.get("postUserName") as! String?,
                                 imageURL: document.get("imageURL") as! String?
                            )
                postList = [] // 初期化
                postList.append(aPost)
                print("append: \(postName), comment: \(postComment)")
                // addAnnotationを追加
                completion(aPost)
            } // for document in documentsここまで
        } // func getDocumentsCompletionここまで
    }  // func getPostListAroundTokyo()ここまで
    
    // コメントを投稿する
    public func addPostDataFromModel(currentUser: UserData, _ name: String, _ latitude: Double, _ longitude: Double, commentText comment: String, omiseImageURL: String?, searchedAndSelectedOmiseUid: String?, searchedAndSelectedOmiseItem: OmiseItem, completion: @escaping () -> ()) {
        // Firestoreのセッティング
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
                
        print("ジオハッシュをイニシャライズします")
        let locationForGeoHash = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let hash = GFUtils.geoHash(forLocation: locationForGeoHash)
        
        // サブコレを使ってFirebaseにデータを追加
        db.collection("locationCollection").document("locationDocument").collection("subLocCollection").addDocument(data: [
            "id": "\(Timestamp(date: Date())), \(name)",
            "name": name,
            "latitude": latitude,
            "longitude": longitude,
            "coordinate": GeoPoint(latitude: latitude, longitude: longitude),
            "geohash": hash,
            "created_at": Timestamp(date: Date()),
            "comment": comment,
            "imageURL": omiseImageURL ?? "",
            "postUserUID": currentUser.uid,
            "postUserName": currentUser.userName ?? "",
            "omiseUID": searchedAndSelectedOmiseUid ?? "",
            "omiseSiteURL": "https:/sample"
        ]){ err in
            if err != nil {
                print("エラー: \(String(describing: err))")
            } else {
                print("ロケーションを追加しました！")
                print("name: \(name)")
                print("latitude: \(latitude)")
                print("longitude: \(longitude)")
                // 完了後の処理
                completion()
            }
        }
    } // addLocationDataここまで
    
    // 報告用メソッド
    func sendReportText(postUID: String, reporterUID: String, reportText: String){
        db.collection("reportCollection").document("reportDocument").collection("subReportCollection").addDocument(data: [
            "postUID": postUID,
            "reporterUID": reporterUID,
            "reportText": reportText
        ]) { error in
            if error != nil {
                print("報告中にエラーが発生しました：\(String(describing:error))")
            } else {
                print("次の内容を報告しました：\(reportText)")
            }
        }
    }
}

class SelectedPost: PostData{
    
}
