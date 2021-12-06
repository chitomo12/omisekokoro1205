//
//  UserData.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/23.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class UserData: ObservableObject {
    @EnvironmentObject var isShowProgress: ShowProgress
    
    @Published var uid: String = ""
    @Published var email: String = ""
    @Published var userName: String? // 最初はnilのためオプショナル型にする
    @Published var profileUIImage: UIImage?
    
    var loginController = LoginController()
    
    let db: Firestore!
    
    init(uid: String, email: String, userName: String) {
        self.uid = uid
        self.email = email
        self.userName = userName
        
        Firestore.firestore().settings = FirestoreSettings()
        db = Firestore.firestore()
    }
    
    // ログイン状態を調べ、ユーザー情報(uid, email, userName)をselfに渡す
    func CheckIfUserLoggedIn(completion: @escaping (Bool) -> ()){
        print("ユーザーのログイン状態を確認します")
        if let loggedInUser = Auth.auth().currentUser {
            print("ログイン中です")
            self.uid = loggedInUser.uid
            self.email = loggedInUser.email!
            loginController.getUserNameFromUid(userUid: loggedInUser.uid, completion: { userName in
                self.userName = userName
                getUserImageFromFirestorage(userUID: loggedInUser.uid, completion: { data in
                    if data != nil {
                        print("プロフィール画像を読み込みます：\(data!)")
                        self.profileUIImage = UIImage(data: data!)
                    } else {
                        print("プロフィール画像が見つかりません")
                        self.profileUIImage = UIImage(named: "SampleImage")
                    }
                    completion(true)
                })
            })
        } else {
            print("ログアウト中です")
            self.uid = "GuestUID"
            self.email = "guest@email"
            self.userName = "Guest"
            self.profileUIImage = UIImage(named: "SampleImage")
            completion(false)
        }
    }
    
    func ChangeUserName(userUID: String, userNewName: String, completion: @escaping () -> ()){
        print("ユーザー名を変更します")
        
        db.collection("userCollection")
            .document("userDocument")
            .collection("subUserCollection")
            .document(userUID)
            .setData(["userName": userNewName]){ error in
                if error != nil {
                    print("ユーザー名更新中にエラーが生じました：\(error!))")
                } else {
                    print("ID: \(userUID) のユーザー名を\(userNewName)に更新しました")
                    completion()
                }
            }
        
        // 名前を変更するユーザーの関連投稿のcreated_by_nameを全て変更する
        db.collection("locationCollection")
            .document("locationDocument")
            .collection("subLocCollection")
            .whereField("postUserUID", isEqualTo: userUID)
            .getDocuments { querySnapshots, error in
                for document in querySnapshots!.documents {
                    self.db.collection("locationCollection")
                        .document("locationDocument")
                        .collection("subLocCollection")
                        .document(document.documentID)
                        .setData(["postUserName" : userNewName], merge: true)
                }
            }
    }
    
    // 指定したユーザーUIDのデバイストークンを取得する
    func getFcmTokenFromUserUID(userUID: String, completion: @escaping (String) -> ()) {
        var fcmToken: String = "dummy"
        
        db.collection("userCollection")
            .document("userDocument")
            .collection("subUserCollection")
            .document(userUID)
            .getDocument{ document, error in
                if let document = document {
                    if document.get("fcmToken") != nil {
                        fcmToken = document.get("fcmToken") as! String
                    }
                }
                completion(fcmToken)
            }
    }
}

//class GuestUserData: UserData {
//    @Published var uid: String = ""
//    @Published var email: String = ""
//}
