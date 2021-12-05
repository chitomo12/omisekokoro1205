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
                    if let authCurrentUser = Auth.auth().currentUser {
                        VStack{
                            // ログイン中のユーザー情報(Environment)
                            Text("\(currentUser.email), \(currentUser.userName!)でログイン中").padding()
                            
                            Button(action: {
                                isShowLoginCheckView = false
                            }){
                                Text("メインページへ")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 40, alignment: .center)
                                    .background(linearGradientForButton)
                                    .cornerRadius(20)
                                    .padding()
                            }
                            
//                            NavigationLink(destination: TabWithAnimationView(currentUser: currentUser).navigationBarHidden(true)){
//                                Text("メインページへ")
//                                    .font(.system(size: 16, weight: .bold, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .frame(width: 200, height: 40, alignment: .center)
//                                    .background(linearGradientForButton)
//                                    .cornerRadius(20)
//                                    .padding()
//                            }
                            
                            // ログアウトボタン
                            Button(action: {
                                loginController.logoutUser()
                                currentUser.uid = ""
                                currentUser.email = ""
                            }) {
                                Text("ログアウトする")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 40, alignment: .center)
                                    .background(linearGradientForButton)
                                    .cornerRadius(20)
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
                                    print("ユーザー名: \(userNameString) を取得しました。")
                                    environmentUserData.userName = userNameString
                                    currentUser.userName = userNameString
                            })
                        }
                    } else {
                        // ログインしていない場合、ログインまたは新規登録のビューを表示する
                        VStack{
                            Text("新規登録").font(.title2).fontWeight(.ultraLight).padding()
                            Text("メールアドレス").fontWeight(.ultraLight)
                            TextField("email", text: $createUserEmail, prompt:
                                Text("emailを入力してください")
                            ).autocapitalization(.none)
                            Text("パスワード").fontWeight(.ultraLight)
                            TextField("パスワード", text: $createUserPassword, prompt:
                                Text("パスワードを入力してください")
                            ).autocapitalization(.none)
                            Divider()
                        }
                        .padding(.horizontal)
                        .onAppear(perform: {
                            loginController.isDidLogout = true
                        })
                        
                        Button(action: {
                            print("新規登録する")
                            loginController.authCreateUser(email: createUserEmail, password: createUserPassword)
                        }) {
                            Text("新規登録します").padding()
                        }
                        if loginController.isCreatingFailed == true {
                            Text("新規登録に失敗しました。").foregroundColor(.red)
                        }
                        
                        NavigationLink(destination: LoginTest(currentUser: currentUser, isShowLoginCheckView: $isShowLoginCheckView) ){
                            Text("ログインする").padding()
                        }
                        
                        NavigationLink(destination: TabWithAnimationView(currentUser: UserData(uid: "Guest UID", email: "Guest@email.com", userName: "Guest Name")).navigationBarHidden(true), isActive: $isStartGuestMode){
                            Text("ゲストモードでログイン")
                                .padding()
                                .onTapGesture{
//                                    environmentUserData.uid = "Guest UID"
//                                    environmentUserData.email = "guest@email"
//                                    environmentUserData.userName = "Guest"
//                                    print("environmentUserData: \(environmentUserData)")
                                    isStartGuestMode = true
                                }
                        }
                    }
    //                NavigationLink(destination: AuthTest().navigationBarHidden(false), isActive: $loginController.isDidLogout ){
    //                    EmptyView()
    //                }
                Spacer()
                }
            }
        }.navigationBarHidden(true)
            .onAppear(perform: {
                print("AuthTestが表示されました")
            }
            )
    }
}

struct AuthTest_Previews: PreviewProvider {
//    @ObservedObject var loginController: LoginController
    
    static var previews: some View {
        AuthTest(isShowLoginCheckView: .constant(true))
    }
}
