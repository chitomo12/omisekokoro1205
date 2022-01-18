//
//  loadComments.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/07.
//

import Foundation
import SwiftUI
import CoreLocation 
import FirebaseFirestore

//// PostIDから投稿を検索する関数。
//// 元はマップビューに複数の吹き出しを読み込み、表示するための関数（ほぼ使ってない？）
//func loadPost(postID: String){
//    print("\(postID)の投稿をロードします")
//
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
//
//    var postList: [Post] = []
//
//    // Firestoreのセッティング
//    var db: Firestore!
//    let settings = FirestoreSettings()
//    Firestore.firestore().settings = settings
//    db = Firestore.firestore()
//
//    db.collection("locationCollection")
//        .document("locationDocument")
//        .collection("subLocCollection")
//        .document(postID)
//        .getDocument() { (querySnapshot, error) in
//            if querySnapshot == nil {
//                print("querySnapshot is nil")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("document: \(String(describing: document.get("name")))")
//                    print("latitude: \(String(describing: document.get("latitude")))")
//                    let postName = String(describing: document.get("name")! )
//                    let postCreatedAt = document.get("created_at") as! Timestamp
//                    let postCreatedAtDate = postCreatedAt.dateValue()
//                    let postCreatedAtString = formatter.string(from: postCreatedAtDate)
//                    let postComment = String(describing: document.get("comment") ?? "" )
//                    let postLatitude = document.get("latitude") as! Double
//                    let postLongitude = document.get("longitude") as! Double
//                    postList.append(Post(name: postName,
//                                         documentId: document.documentID,
//                                         created_at: postCreatedAtString,
//                                         comment: postComment,
//                                         coordinate: CLLocationCoordinate2D(latitude: postLatitude, longitude: postLongitude),
//                                         created_by: document.get("postUserUID") as! String?
//                                         )
//                                    )
//                }
//                if error != nil {
//                    print("error: \(String(describing: error))")
//                }
//            }
//        }
//}
