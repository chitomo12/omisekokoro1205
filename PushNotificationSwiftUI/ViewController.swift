//
//  ViewController.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/10/31.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import UIKit
import GeoFire

class ViewController: UIViewController {
    @State var isShowingDetailContent: Bool = false
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    // コメントを投稿する
    public func addPostData(currentUser: UserData, _ name: String, _ latitude: Double, _ longitude: Double, commentText comment: String, omiseImageURL: String?, searchedAndSelectedOmiseUid: String?, searchedAndSelectedOmiseItem: OmiseItem, completion: @escaping () -> ()) {
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
    
    public func completion(_ postList: [Post]){
        print(postList)
        
    }
    
}
