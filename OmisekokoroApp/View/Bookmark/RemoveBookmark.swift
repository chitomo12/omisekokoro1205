//
//  RemoveBookmark.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI
import Firebase

func RemoveBookmark(postID: String, userID: String, completion: @escaping () -> () ){
    // documentIDから検索して削除する
    let db: Firestore!
    Firestore.firestore().settings = FirestoreSettings()
    db = Firestore.firestore()
    
    print("ブックマークを削除します")
    
    db.collection("bookmarkCollection")
        .document("bookmarkDocument")
        .collection("subBookmarkCollection")
        .whereField("postID", isEqualTo: postID)
        .whereField("userID", isEqualTo: userID)
        .getDocuments { querySnapshots, error in
            guard let documents = querySnapshots?.documents else{
                print("error")
                return
            }
            for document in documents {
                db.collection("bookmarkCollection")
                    .document("bookmarkDocument")
                    .collection("subBookmarkCollection")
                    .document(document.documentID)
                    .delete()
            }
            completion()
        }
}
