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
    @State var isShowLoginCheckView = false
    
    @State var agreement = false
    
    @State var errorText: String? = ""
    
    var body: some View {
        // ログインしていない場合、ログインまたは新規登録のビューを表示する
        VStack{
            Text("新規登録").font(.title2).fontWeight(.ultraLight).padding()
            
            Text("メールアドレス").fontWeight(.ultraLight)
            TextField("email", text: $inputUserEmail, prompt:
                Text("emailを入力してください")
            ).autocapitalization(.none)
            
            Divider()
            
            Text("パスワード").fontWeight(.ultraLight)
            TextField("パスワード", text: $inputUserPassword, prompt:
                Text("パスワードを入力してください")
            ).autocapitalization(.none)
            
            Divider()
        
            Toggle(isOn: $agreement) {
                Text("利用規約に合意する")
            }.padding()
            
            // エラーメッセージ
            if errorText != nil {
                Text(errorText!).foregroundColor(.red)
            }
            
            Button(action: {
                print("新規登録します")
                if agreement == false {
                    errorText = "利用規約への合意が必要です"
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
//                Text("新規登録します").padding()
                RedButtonView(buttonText: "新規登録").padding()
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
    }
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView()
//    }
//}
