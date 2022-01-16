//
//  LoginController.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/18.
//

import SwiftUI
import Foundation
import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

class LoginController: ObservableObject {
    @EnvironmentObject var environmentFcmToken: FcmToken
    @Published var isGuestMode = IsGuestMode()
//    var appDelegate = AppDelegate()
    
    @Published var errorMessage: String = ""
    @Published var isCreatingFailed: Bool = false
    @Published var isSentVerificationEmail: Bool = false 
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
    
    @Published var newRegisteredUserName: String = ""
    
    @Published var isSentVerificationEmailMessage: String = ""
    @Published var isNavigateToLoginView: Bool = false
    
    // Firestoreのセッティング
    var db: Firestore!
    let settings = FirestoreSettings()
    init(){
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    // ユーザー新規登録のためのメソッド
    func authCreateUser(email: String, password: String, completion: @escaping (Error) -> ()) async {
        
        await Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print("エラー：\(String(describing: error))")
                self.isCreatingFailed = true
                self.errorMessage = String(describing: error!)
                completion(error!)
                self.isLoading = false
            } else {
                print("成功：\(String(describing: authResult))")
                
                print("認証用メールを送ります")
                let user = authResult?.user
                user?.sendEmailVerification(completion: { error in
                    print("エラー：\(String(describing: error))")
                    if error == nil {
                        print("認証用メールを送信しました。")
                        self.isSentVerificationEmail = true
                        // 認証用メールを送ったらFirebaseにメール、UID、ユーザー名を登録
                        self.RegisterUserName(registeringUser: UserData(uid: user?.uid ?? "",
                                                                        email: user?.email ?? "",
                                                                        userName: self.newRegisteredUserName),
                                              completion: {
                            print("ユーザー名を登録しました: \(UserData(uid: user?.uid ?? "", email: user?.email ?? "", userName: self.newRegisteredUserName))")
                            // メールの送信に成功したらログアウトする
                            self.logoutUser(completion: {
                                print("サインアウトしました")
//                                self.isSentVerificationEmailMessage = "認証メールを送信しました"
                                self.isSentVerificationEmail = true
//                                self.isGuestMode.guestModeSwitch = true
                                self.isNavigateToLoginView = true
                                self.isLoading = false
                            })
                        })
                    } else {
                        self.isLoading = false
                    }
                })
            }
        }
    }
    
    // ログインのためのメソッド
    func authLoginUser(email: String, password: String, deviceToken: String) {
        self.errorMessage = ""
        print("authLoginUserを実行")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if error != nil {
                print("error: \(String(describing: error))")
                self?.errorMessage = "ログインに失敗しました"
                self?.isLoading = false 
            } else if let user = authResult?.user {
                if user.isEmailVerified == false {
                    // メール認証が完了していない場合
                    self?.errorMessage = "メール認証が完了していません。\n認証メールを再送します。"
                    user.sendEmailVerification { error in
                        if error == nil {
                            print("認証用メールを送信しました。")
                            // メールの送信に成功したらログアウトする
                            self?.logoutUser(completion: {
                                print("サインアウトしました")
                            })
                        } else {
                            print("認証メール送信中にエラーが発生しました")
                        }
                    }
                    self?.isLoading = false
                } else {
                    print("email認証済みです")
                    guard let strongSelf = self else { return }
                    print("strongSelf: \(strongSelf)")
                    if error != nil {
                        print("ログインエラー：\(String(describing: error))")
                        self?.isLoading = false
                    } else {
                        print("ログイン成功")
                        if let user = Auth.auth().currentUser {
                            
                            // FCMトークンを発行＆登録
                            if let authCurrentUser = Auth.auth().currentUser{
                                self!.setFcmTokenToFirestore(
                                    userUid: authCurrentUser.uid,
                                    fcmToken: deviceToken) {
                                        print("FCMトークンを更新しました")
                                    }
                            }
                            
                            print("user.uid: \(user.uid), user.email: \(user.email ?? "")")
                            self!.loggedInUserUID = user.uid
                            self!.loggedInUserEmail = user.email ?? ""
                            
                            // ユーザーの名前がFirestoreに登録されているかどうかを判定
                            self!.CheckIfUserNameRegistered(userUid: user.uid, completion: { isRegistered in
                                print("check if user name registered: result -> \(isRegistered)")
                                self!.isUserNameRegistered = isRegistered
                                // resultに関わらず、ログイン完了判定をプロパティに格納する
                                self!.isLoginSuccessed = true
                                self!.isDidLogin = true
                                self!.isDidLogout = false
                            })
                        }
                        self?.isLoading = false
                    }
                }
            } else {
                print("some error")
                self?.isLoading = false
            }
        }
    }
    
    func logoutUser(completion: @escaping () -> () ){
        // プッシュ通知が誤送されないよう、ログアウト前にfcmTokenをリセットする
        if let authCurrentUser = Auth.auth().currentUser{
            let targetUserUID = authCurrentUser.uid
            print("\(targetUserUID)のfcmTokenを初期化します")
            self.setFcmTokenToFirestore(
                userUid: targetUserUID,
                fcmToken: "default") {
                    print("\(targetUserUID)のfcmTokenを初期化しました")
                    
                    // トークンリセット後、サインアウトの処理を実行
                    do{
                        try Auth.auth().signOut()
                        self.isDidLogout = true
                        print("サインアウトしました")
                        completion()
                    } catch let signOutError as NSError {
                        print("サインアウト中にエラーが発生しました：\(signOutError)")
                    }
                }
        }
    }
    
    func CheckIfUserNameRegistered(userUid: String, completion: @escaping(Bool) -> Void) {
        print(#function)
        print("Uid:\(userUid)さんの名前が登録されているか確認します。")
        
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
    func RegisterUserName(registeringUser: UserData, completion: @escaping () -> Void) {
        self.isLoading = true 
        print("名前：\(registeringUser.userName)を\(registeringUser.uid)に登録します")
        
        // サブコレを使ってFirebaseにデータを追加
        db.collection("userCollection").document("userDocument").collection("subUserCollection").document(registeringUser.uid).setData([
            "userId": registeringUser.uid,
            "userEmail": registeringUser.email,
            "userName": registeringUser.userName,
            "created_at": Timestamp(date: Date())
        ]){ err in
            if err != nil {
                print("エラー: \(String(describing: err))")
            } else {
                print("新規ユーザー名を登録しました！")
                print("userId: \(registeringUser.uid)")
                print("userEmail: \(registeringUser.email)")
                print("userName: \(registeringUser.userName)")
                print("created_at: \(Timestamp(date: Date()))")
                
                self.isGuestMode.guestModeSwitch = false
                
                // プッシュ通知用FCMトークンを取得し、環境変数に格納する。
                Messaging.messaging().token { token, error in
                  if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                  } else if let token = token {
                    print("FCM registration token: \(token)")
//                        self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
//                      environmentFcmToken.fcmTokenString = token
                      self.setFcmTokenToFirestore(userUid: registeringUser.uid, fcmToken: token, completion: { print("トークンを更新") })
                      completion()
                  }
                }
//                self.setFcmTokenToFirestore(userUid: registeringUser.uid, fcmToken: "testToken")
//
//                completion()
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
                        print("ユーザー名「\(userName)」を取得しました")
                        completion(userName)
                    }
                }
            }
    }
    
    // FCMトークンをユーザーに紐付けるメソッド
    func setFcmTokenToFirestore(userUid: String, fcmToken: String, completion: @escaping () -> () ){
        print("fcmToken「\(fcmToken)」をuserUid「\(userUid)」に登録します")
        
        db.collection("userCollection")
            .document("userDocument")
            .collection("subUserCollection")
            .document(userUid)
            .setData([
                "userId": userUid,
                "fcmToken": fcmToken
            ], merge: true ) { error in
                if error != nil{
                    print("エラー：\(String(describing: error))")
                } else {
                    completion()
                }
            }
    }
}

