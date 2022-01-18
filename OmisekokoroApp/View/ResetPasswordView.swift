//
//  ResetPasswordView.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/13.
//

import SwiftUI
import FirebaseAuth
//import AuthenticationServices

struct ResetPasswordView: View {
    @State var inputMailAddress: String = ""
    @State var isSentPasswordResetEmail: Bool = false
    
    var body: some View {
        VStack{
            Text("パスワードを再設定")
            TextField("メールアドレスを入力してください", text: $inputMailAddress, prompt: Text("メールアドレス"))
            
            if isSentPasswordResetEmail == true {
                // パスワード再設定メールを送信した場合
                Text("パスワード再設定メールを送信しました").foregroundColor(.blue).padding()
            }
            
            Button(action: {
                print("\(inputMailAddress)にパスワード再設定メールを送信します")
                Auth.auth().sendPasswordReset(withEmail: inputMailAddress) { error in
                    if error != nil {
                        print("パスワード再設定メールの送信に失敗")
                    } else {
                        print("パスワード再設定メールを送信しました")
                        isSentPasswordResetEmail = true 
                    }
                }
            }, label: {
                Text("パスワードを再設定")
            })
        }
        .padding()
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
