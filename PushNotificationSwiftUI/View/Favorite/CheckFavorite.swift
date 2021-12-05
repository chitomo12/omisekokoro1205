//
//  CheckFavorite.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI
import Firebase

// Favoriteしたかどうかを判定
func CheckFavorite(postID: String, currentUserID: String, completion: @escaping (Bool, String) -> ()) {
    let db: Firestore!
    Firestore.firestore().settings = FirestoreSettings()
    db = Firestore.firestore()
    
    print("postID:\(postID)を探します")
    
    db.collection("favCollection")
        .document("favDocument")
        .collection("subFavCollection")
        .whereField("postID", isEqualTo: postID)
        .whereField("userID", isEqualTo: currentUserID)
        .getDocuments(completion: { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("データがありません")
                return
            }
            if documents.count >= 1 {
                print("お気に入りが\(documents.count)個存在しました")
                completion(true, documents[0].documentID)
            } else {
                print("お気に入りが存在しません")
                completion(false, "none")
            }
        })
}
