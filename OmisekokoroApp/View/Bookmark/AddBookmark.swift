//
//  AddBookmark.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI
import Firebase

func AddBookmark(postID: String, userID: String, completion: @escaping () -> () ){
    let db: Firestore!
    Firestore.firestore().settings = FirestoreSettings()
    db = Firestore.firestore()
    
    print("ブックマークを追加します")
    db.collection("bookmarkCollection")
        .document("bookmarkDocument")
        .collection("subBookmarkCollection")
        .addDocument(
        data: ["postID" : postID,
               "userID": userID,
               "created_at": Timestamp(date: Date())
              ]
    ){ error in
        if error != nil {
            print("error: \(String(describing: error))")
        } else {
            print("AddBookmarkが成功しました")
            print("postID: \(postID)")
            print("userID: \(userID)")
            // 追加後にドキュメントIDを渡す
            completion()
        }
    }
}
