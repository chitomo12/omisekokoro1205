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
    
    var body: some View {
        // ログインしていない場合、ログインまたは新規登録のビューを表示する
        VStack{
            Text("新規登録").font(.title2).fontWeight(.ultraLight).padding()
            Text("メールアドレス").fontWeight(.ultraLight)
            TextField("email", text: $inputUserEmail, prompt:
                Text("emailを入力してください")
            ).autocapitalization(.none)
            Text("パスワード").fontWeight(.ultraLight)
            TextField("パスワード", text: $inputUserPassword, prompt:
                Text("パスワードを入力してください")
            ).autocapitalization(.none)
            
            Divider()
            
            Button(action: {
                print("新規登録する")
                loginController.authCreateUser(email: inputUserEmail, password: inputUserPassword)
            }) {
                Text("新規登録します").padding()
            }
            
            // 登録したらログイン後の名前登録画面に移行
            NavigationLink(destination: DidLoginTest(environmentCurrentUserData: _environmentUserData,
                                                     loginController: loginController,
                                                     currentUser: environmentUserData,
                                                     isShowLoginCheckView: $isShowLoginCheckView),
                           isActive: $loginController.isDidLogin) {
                EmptyView()
            }
        }
        .padding(.horizontal)
        .onAppear(perform: {
            loginController.isDidLogout = true
        })
        
    }
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView()
//    }
//}
