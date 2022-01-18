//
//  AddFavorite.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI
import Firebase
import FirebaseFirestore

func AddFavorite(postID: String, userID: String, completion: @escaping () -> () ){
    let db: Firestore!
    Firestore.firestore().settings = FirestoreSettings()
    db = Firestore.firestore()
    
    db.collection("favCollection").document("favDocument").collection("subFavCollection").addDocument(
        data: ["postID" : postID,
               "userID": userID,
               "created_at": Timestamp(date: Date())
              ]
    ){ error in
        if error != nil {
            print("error: \(String(describing: error))")
        } else {
            print("AddFavoriteが成功しました")
            print("postID: \(postID)")
            print("userID: \(userID)")
            // 追加後にドキュメントIDを渡す
            completion()
        }
    }
}
