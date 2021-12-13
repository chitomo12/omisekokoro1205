//
//  LoginTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/18.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct AuthTest: View {
    @EnvironmentObject var environmentUserData: UserData
    @EnvironmentObject var isGuestMode: IsGuestMode
    
    @ObservedObject var loginController = LoginController()
    
    @Binding var isShowLoginCheckView: Bool
    
    @State var isLoginFailed = false
    @State var createUserEmail = ""
    @State var createUserPassword = ""
    
    @State var isStartGuestMode = false
    
    let linearGradientForButton = LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    // 現在ログイン中のユーザー情報
    @ObservedObject var currentUser = UserData(uid: "default", email: "default", userName: "default")
    
    @State var downloadedUIImageData: Data? = nil
    
    var body: some View {
//        let bounds = UIScreen.main.bounds
//        let screenWidth = bounds.width
        
        NavigationView{
            ZStack {
                VStack{
                    Image("omisekokoroLogo")
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                        .scaledToFill()
                        .padding(.top, 80)
                    
                    // ログインしている場合、ログイン中のユーザー情報を表示
                    if let authCurrentUser = Auth.auth().currentUser, environmentUserData.userName != nil {
                        VStack{
                            // ログイン中のユーザー情報(Environment)
                            Text("\(environmentUserData.userName!)でログイン中").padding()
                            
                            Button(action: {
                                isShowLoginCheckView = false
                            }){
                                RedButtonView(buttonText: "メインページへ")
                            }
                            
                            // ログアウトボタン
                            Button(action: {
                                loginController.logoutUser(completion: {
                                    print("サインアウトしました")
                                })
                                currentUser.uid = ""
                                currentUser.email = ""
                            }) {
                                RedButtonView(buttonText: "ログアウトする")
                            }
                        }
                        .onAppear{
                            loginController.isDidLogout = false
                            
                            // EnvironmentObject
                            print("environmentUserData.uid: \(authCurrentUser.uid)")
                            environmentUserData.uid = authCurrentUser.uid
                            environmentUserData.email = authCurrentUser.email ?? ""
                            getUserImageFromFirestorage(userUID: authCurrentUser.uid, completion: { data in
                                if data != nil {
                                    print("プロフィール画像を読み込みます：\(data!)")
                                    environmentUserData.profileUIImage = UIImage(data: data!)
                                } else {
                                    print("プロフィール画像が見つかりません")
                                    environmentUserData.profileUIImage = UIImage(named: "SampleImage")
                                }
                            })
                            
                            // ObservedObject
                            currentUser.uid = authCurrentUser.uid
                            currentUser.email = authCurrentUser.email ?? ""
                            
                            // UIDでFirestoreからユーザー名を取得する
                            loginController.getUserNameFromUid(
                                userUid: authCurrentUser.uid,
                                completion: { userNameString in
                                    print("ユーザー名: \(String(describing: userNameString)) を取得しました。")
                                    environmentUserData.userName = userNameString
                                    currentUser.userName = userNameString
                            })
                            
                            // ゲストモードを解除
                            isGuestMode.guestModeSwitch = false
                        }
                    } else {
                        
                        // ログインしていない場合、ログインまたは新規登録のビューを表示する
                        
                        // 認証メール送信後はメッセージを表示
//                        if loginController.isSentVerificationEmailMessage.isEmpty == false {
                            Text("\(loginController.isSentVerificationEmailMessage)")
//                        }
                        
                        // 新規登録画面へ
                        NavigationLink(destination: RegisterView(loginController: loginController), label: {
                            RedButtonView(buttonText: "新規登録")
                        })
                        
                        
                        NavigationLink(destination: LoginTest(currentUser: currentUser, isShowLoginCheckView: $isShowLoginCheckView) ){
                            RedButtonView(buttonText: "ログイン")
                        }
                        
                        
                        Button(action: {
                            environmentUserData.uid = "Guest UID"
                            environmentUserData.email = "guest@email"
                            environmentUserData.userName = "Guest"
                            isStartGuestMode = true
                            isShowLoginCheckView = false
                        }) {
                            Text("ゲストモードでログイン")
                                .padding()
                        }
                    }
                Spacer()
                }
            }
            .onAppear(perform: {
                print("AuthTestが表示されました")
            })
        }.navigationBarHidden(true)
    }
}

struct AuthTest_Previews: PreviewProvider {
//    @ObservedObject var loginController: LoginController
    
    static var previews: some View {
        AuthTest(isShowLoginCheckView: .constant(true))
    }
}
