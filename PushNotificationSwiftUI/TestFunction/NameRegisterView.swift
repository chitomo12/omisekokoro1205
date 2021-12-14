//
//  NameRegisterView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/26.
//

import SwiftUI

struct NameRegisterView: View {
    @EnvironmentObject var isGuestMode: IsGuestMode
    
    @ObservedObject var currentUser: UserData
    
    @ObservedObject var loginController = LoginController()
    
    @State var inputText: String = ""
    @State var isFinishRegistering: Bool = false
    
    // ナビゲーションリンク発火のためのBoolean
    @State var isNavigatedToMainPage: Bool = false
    
    var body: some View {
        ZStack {
            VStack{
                Text("ユーザー名を入力してください")
                Text("ユーザー名はアプリ内で表示される名前です").font(.caption)
                TextField("お名前", text: $inputText, prompt: Text("お名前"))
                Button(action:{
                    loginController.isLoading = true
                    print("名前を登録します")
                    loginController.RegisterUserName(registeringUser: currentUser, completion: {
                        print("HelloUserビューに移ります")
                        isNavigatedToMainPage = true 
                    })
                }){
                    Text("登録")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 40, alignment: .center)
                        .background(Color("ColorOne"))
                        .cornerRadius(20)
                        .padding()
                }
            }
            .padding(.horizontal)
            .onAppear {
                // 名前を登録していない場合はポップオーバーを名前登録画面にする
            }
            
            if loginController.isLoading == true {
                // ローディングアニメーション
                ProgressView("Loading")
            }
            
            NavigationLink(destination: HelloUser(currentUserData: currentUser, currentUserName: $inputText), isActive: $isNavigatedToMainPage){
                EmptyView()
            }
        }
    }
}

struct NameRegisterView_Previews: PreviewProvider {
//    @ObservedObject var loginController = LoginController()
    static var previews: some View {
        NameRegisterView(currentUser: UserData(uid: "sampleUid", email: "sample@email", userName: "sample name"))
    }
}
