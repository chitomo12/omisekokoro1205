//
//  RemoveFavorite.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI
import Firebase

func RemoveFavorite(postID: String, userID: String, completion: @escaping () -> () ){
    // documentIDから検索して削除する
    let db: Firestore!
    Firestore.firestore().settings = FirestoreSettings()
    db = Firestore.firestore()
    
    db.collection("favCollection")
        .document("favDocument")
        .collection("subFavCollection")
        .whereField("postID", isEqualTo: postID)
        .whereField("userID", isEqualTo: userID)
        .getDocuments { querySnapshots, error in
            guard let documents = querySnapshots?.documents else{
                return
            }
            
            for document in documents {
                print("ドキュメントID：\(document.documentID)を削除します")
                
                db.collection("favCollection")
                    .document("favDocument")
                    .collection("subFavCollection")
                    .document(document.documentID)
                    .delete()
            }
            completion()
        }
}
