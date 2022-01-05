//
//  deleteComment.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/16.
//

import Foundation
import SwiftUI
import CoreLocation
import FirebaseFirestore

func deleteComment(targetDocumentID: String){
    // Firestoreのセッティング
    var db: Firestore!
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    db = Firestore.firestore()
    
    db.collection("locationCollection")
        .document("locationDocument")
        .collection("subLocCollection")
        .document(targetDocumentID)
        .delete() { err in
            if let err = err {
                print("コメント削除中にエラーが発生しました: \(err)")
            } else {
                print("コメントを削除しました")
            }
        }
    
    // 関連するファボ、ブックマーク全てを削除
    db.collection("bookmarkCollection")
        .document("bookmarkDocument")
        .collection("subBookmarkCollection")
        .whereField("postID", isEqualTo: targetDocumentID)
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
        }
}
