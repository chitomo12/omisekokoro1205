//
//  LoginView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/18.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var environmentFcmToken: FcmToken
    
    @ObservedObject var loginController = LoginController()
    @ObservedObject var currentUser: UserData
    
    @Binding var isShowLoginCheckView: Bool
    
    @State var loginUserEmail = ""
    @State var loginUserPassword = ""
    @State var isDidLogin = ""
    
    var body: some View {
        ZStack{
            VStack{
                Text("ログイン").padding(.all)
                
                Group{
                    Text("メールアドレス").fontWeight(.ultraLight)
                    TextField("email", text: $loginUserEmail, prompt:
                        Text("emailを入力してください")
                    ).autocapitalization(.none)
                }
                
                Group{
                    Text("パスワード").fontWeight(.ultraLight)
                    TextField("パスワード", text: $loginUserPassword, prompt:
                        Text("パスワードを入力してください")
                    ).autocapitalization(.none)
                    Divider()
                }
                
                Button(action: {
                    loginController.isLoading = true
                    print("ログインします")
                    loginController.authLoginUser(email: loginUserEmail,
                                                  password: loginUserPassword,
                                                  deviceToken: environmentFcmToken.fcmTokenString)
                }) {
                    Text("ログイン").padding()
                }
                if loginController.isCreatingFailed == true {
                    Text("ログインに失敗しました。").foregroundColor(.red)
                }
                if loginController.errorMessage.isEmpty == false {
                    Text("\(loginController.errorMessage)").foregroundColor(.red)
                }
                
                NavigationLink(destination: ResetPasswordView()){
                    Text("パスワードを忘れた").padding()
                }
            }
            .padding(.horizontal, 30)

            if loginController.isLoading == true {
                ProgressView()
                    .frame(width: 200, height: 300, alignment: .center)
                    .background(Color.white)
                    .opacity(0.9)
            }
        }
        
        NavigationLink(destination: DidLoginView(loginController: loginController,
                                                 currentUser: currentUser,
                                                 isShowLoginCheckView: $isShowLoginCheckView).navigationBarHidden(true),
                       isActive: $loginController.isDidLogin ){
            EmptyView()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(currentUser: UserData(uid: "sample", email: "sample@email.com", userName: ""), isShowLoginCheckView: .constant(true))
    }
}
