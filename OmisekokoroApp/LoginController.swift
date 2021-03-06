//
//  LoginController.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/18.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LoginController: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var isCreatingFailed: Bool = false
    @Published var isLoginSuccessed: Bool = false
    
    // ログインしたかどうかの判定
    @Published var isDidLogin: Bool = false
    
    // ユーザー情報
    @Published var loggedInUserUID: String? = ""
    @Published var loggedInUserName: String = ""
    @Published var loggedInUserEmail: String? = ""
    
    // 名前が登録されているかどうかを判定
    @Published var isUserNameRegistered: Bool = false
    
    // ログアウトの判定
    @Published var isDidLogout: Bool = false
    
    // 何らかのロード処理
    @Published var isLoading: Bool = false 
    
    // ユーザー新規登録のためのメソッド
    func authCreateUser(email: String, password: String){
        _ = Auth.auth().addStateDidChangeListener{ auth, user in
            print("auth: \(auth)")
            print("user: \(String(describing: user))")
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print("エラー：\(String(describing: error))")
                self.isCreatingFailed = true
                self.errorMessage = String(describing: error!)
            } else {
                print("成功：\(String(describing: authResult))")
            }
        }
    }
    
    // ログインのためのメソッド
    func authLoginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            print("strongSelf: \(strongSelf)")
            if error != nil {
                print("ログインエラー：\(String(describing: error))")
            } else {
                print("ログイン成功")
                if let user = Auth.auth().currentUser {
                    print("user.uid: \(user.uid), user.email: \(user.email ?? "")")
                    self!.loggedInUserUID = user.uid
                    self!.loggedInUserEmail = user.email ?? ""
                    
                    // ユーザーの名前がFirestoreに登録されているかどうかを判定
                    self!.CheckIfUserNameRegistered(userUid: user.uid, completion: { isRegistered in
                        print("result: \(isRegistered)")
                        self!.isUserNameRegistered = isRegistered
                        // resultに関わらず、ログイン完了判定をプロパティに格納する
                        self!.isLoginSuccessed = true
                        self!.isDidLogin = true
                        self!.isDidLogout = false
                    })
                }
            }
        }
    }
    
    func logoutUser(){
        do{
            try Auth.auth().signOut()
            self.isDidLogout = true
        } catch let signOutError as NSError {
            print("サインアウト中にエラーが発生しました：\(signOutError)")
        }
        print("サインアウトします")
    }
    
    // Firestoreのセッティング
    var db: Firestore!
    let settings = FirestoreSettings()
    init(){
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func CheckIfUserNameRegistered(userUid: String, completion: @escaping(Bool) -> Void) {
        print(#function)
        print("Uid:\(userUid)さんの名前が登録されているか確認します。")
        
//        // Firestoreのセッティング
//        var db: Firestore!
//        let settings = FirestoreSettings()
//        Firestore.firestore().settings = settings
//        db = Firestore.firestore()
        
        db.collection("userCollection")
            .document("userDocument")
            .collection("subUserCollection")
            .document(userUid)
            .getDocument() { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("ドキュメントが存在しました: \(dataDescription)。名前の登録を確認します")
                    if let userName = document.get("userName") {
                        print("\(userName)で登録が確認されました")
                        self.loggedInUserName = userName as? String ?? ""
                        self.isUserNameRegistered = true
                    } else {
                        print("名前が登録されていません。登録画面に移ります。")
                        self.isUserNameRegistered = false
                    }
                } else {
                    print("ドキュメントが存在しません")
                    self.isUserNameRegistered = false
                }
                completion(self.isUserNameRegistered)
            }
    }
    
    // 名前を登録する
    func RegisterUserName(registeringUser: UserData, registeringName: String, completion: @escaping () -> Void) {
        self.isLoading = true 
        print("名前：\(registeringName)を\(registeringUser.uid)に登録します")
        
        // サブコレを使ってFirebaseにデータを追加
        db.collection("userCollection").document("userDocument").collection("subUserCollection").document(registeringUser.uid).setData([
            "userId": registeringUser.uid,
            "userEmail": registeringUser.email,
            "userName": registeringName,
            "created_at": Timestamp(date: Date())
        ]){ err in
            if err != nil {
                print("エラー: \(String(describing: err))")
            } else {
                print("ユーザーを追加しました！")
                print("userId: \(registeringUser.uid)")
                print("userEmail: \(registeringUser.email)")
                print("userName: \(registeringName)")
                print("created_at: \(Timestamp(date: Date()))")
                
                completion()
            }
            self.isLoading = false
        }
    }
    
    func getUserNameFromUid(userUid: String, completion: @escaping (String?) -> ()){
        print("UIDからユーザー名を取得します。")
        
        var userName: String?
        
        db.collection("userCollection")
            .document("userDocument")
            .collection("subUserCollection")
            .document(userUid)
            .getDocument { document, error in
                if error != nil {
                    print("エラー: \(String(describing:error))")
                } else {
                    if let document = document {
                        userName = document.get("userName") as? String
                    }
                }
                completion(userName)
            }
    }
}
