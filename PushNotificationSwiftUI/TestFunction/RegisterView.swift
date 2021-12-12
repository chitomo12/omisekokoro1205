//
//  RegisterView.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/06.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var environmentUserData: UserData
    
    @ObservedObject var loginController: LoginController
    
    @State var inputUserEmail: String = ""
    @State var inputUserPassword: String = ""
    @State var inputUserName: String = ""
    @State var isShowLoginCheckView = false
    
    @State var agreement = false
    
    @State var errorText: String? = ""
    
    @State var isShowRiyouKiyaku = false
    
    var body: some View {
        // ログインしていない場合、ログインまたは新規登録のビューを表示する
        VStack{
            Text("新規登録").font(.title2).fontWeight(.ultraLight).padding()
            
            Group {
                Text("メールアドレス").fontWeight(.ultraLight)
                TextField("email", text: $inputUserEmail, prompt:
                    Text("emailを入力してください")
                ).autocapitalization(.none)
            }
            
            Divider()
            
            VStack{
                Text("パスワード").fontWeight(.ultraLight)
                TextField("パスワード", text: $inputUserPassword, prompt:
                    Text("パスワードを入力してください")
                ).autocapitalization(.none)
            }
            
            Divider()
            
            VStack{
                Text("ユーザー名").fontWeight(.ultraLight)
                TextField("ユーザー名", text: $inputUserName, prompt:
                    Text("ユーザー名を入力してください")
                ).autocapitalization(.none)
            }
            
            Divider()
        
            VStack{
                Toggle(isOn: $agreement) {
                    Text("利用規約に合意する")
                }.padding()
                
                Text("利用規約")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        isShowRiyouKiyaku = true
                    }
            }
            
            // エラーメッセージ
            if errorText != nil {
                Text(errorText!).foregroundColor(.red)
            }
            
            if loginController.isSentVerificationEmail == false {
                Button(action: {
                    print("新規登録します")
                    if agreement == false {
                        errorText = "利用規約への合意が必要です"
                    } else if inputUserEmail.isEmpty || inputUserName.isEmpty {
                        errorText = "メールアドレス、パスワード、ユーザー名を入力してください"
                    } else {
                        loginController.authCreateUser(email: inputUserEmail, password: inputUserPassword) { error in
                            if error.localizedDescription == "The password must be 6 characters long or more." {
                                errorText = "パスワードは最低６文字必要です"
                            } else if error.localizedDescription == "An email address must be provided." {
                                errorText = "メールアドレスが入力されていません"
                            } else if error.localizedDescription == "The email address is badly formatted." {
                                errorText = "メールアドレスの形式が正しくありません"
                            }
                        }
                    }
                }) {
                    RedButtonView(buttonText: "新規登録").padding()
                }
            } else {
                // 認証メール送信後
                Text("認証メールを送りました")
                    .foregroundColor(Color.blue)
            }
        }
        .padding(.horizontal, 30)
        .onAppear(perform: {
            loginController.isDidLogout = true
        })
        
        // 登録したらログイン後の名前登録画面に移行
        NavigationLink(destination: DidLoginTest(environmentCurrentUserData: _environmentUserData,
                                                 loginController: loginController,
                                                 currentUser: environmentUserData,
                                                 isShowLoginCheckView: $isShowLoginCheckView),
                       isActive: $loginController.isDidLogin) {
            EmptyView()
        }
        
        // 登録ボタンを押して認証メールを送ったらログイン画面に移行
        NavigationLink(destination: LoginTest(currentUser: environmentUserData,
                                              isShowLoginCheckView: $isShowLoginCheckView)
        ){
            EmptyView()
        }
        
                       // 利用規約表示用のシート
                       .sheet(isPresented: $isShowRiyouKiyaku) {
                           NavigationView{
                               RiyouKiyakuView()
                           }
                       }
    }
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView()
//    }
//}
