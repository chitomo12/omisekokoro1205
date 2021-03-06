//
//  ContentView.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/04.
//

import SwiftUI

struct LoginTest: View {
    @ObservedObject var loginController = LoginController()
    @ObservedObject var currentUser: UserData
    
    @Binding var isShowLoginCheckView: Bool
    
    @State var loginUserEmail = ""
    @State var loginUserPassword = ""
    @State var isDidLogin = ""
    
    var body: some View {
        NavigationView{
            VStack{
                Text("ログイン").padding(.horizontal)
                Text("メールアドレス").fontWeight(.ultraLight)
                TextField("email", text: $loginUserEmail, prompt:
                    Text("emailを入力してください")
                ).autocapitalization(.none)
                Text("パスワード").fontWeight(.ultraLight)
                TextField("パスワード", text: $loginUserPassword, prompt:
                    Text("パスワードを入力してください")
                ).autocapitalization(.none)
                Divider()
                Button(action: {
                    print("ログインします")
                    loginController.authLoginUser(email: loginUserEmail, password: loginUserPassword)
                }) {
                    Text("ログイン").padding()
                }
                if loginController.isCreatingFailed == true {
                    Text("ログインに失敗しました。").foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        NavigationLink(destination: DidLoginTest(loginController: loginController,
                                                 currentUser: currentUser,
                                                 isShowLoginCheckView: $isShowLoginCheckView).navigationBarHidden(true),
                       isActive: $loginController.isDidLogin ){
            EmptyView()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
