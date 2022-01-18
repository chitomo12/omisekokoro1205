//
//  CheckBookmark.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI
import Firebase

// ブックマークしたかどうかを判定
func CheckBookmark(postID: String, currentUserID: String, completion: @escaping (Bool, String) -> ()) {
    let db: Firestore!
    Firestore.firestore().settings = FirestoreSettings()
    db = Firestore.firestore()
    
    print("postID:\(postID)を探します")
    
    db.collection("bookmarkCollection")
        .document("bookmarkDocument")
        .collection("subBookmarkCollection")
        .whereField("postID", isEqualTo: postID)
        .whereField("userID", isEqualTo: currentUserID)
        .getDocuments(completion: { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("データがありません")
                return
            }
            if documents.count >= 1 {
                print("ブックマークが\(documents.count)個存在しました")
                completion(true, documents[0].documentID)
            } else {
                print("ブックマークが存在しません")
                completion(false, "none")
            }
        })
}
