//
//  DidLoginTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/18.
//

import SwiftUI

struct DidLoginTest: View {
    @EnvironmentObject var environmentCurrentUserData: UserData
    @EnvironmentObject var isGuestMode: IsGuestMode
    
    @ObservedObject var loginController: LoginController
    @ObservedObject var currentUser: UserData
    
    @Binding var isShowLoginCheckView: Bool 
    
    var body: some View {
        VStack{
            
            if loginController.isUserNameRegistered == false {
                // ユーザー名が登録されていない場合は登録画面に案内する
                Text("はじめまして！")
                NavigationLink(
                    destination: NameRegisterView(
                        currentUser: UserData(uid: loginController.loggedInUserUID!,
                                              email: loginController.loggedInUserEmail!,
                                              userName: ""))
                        .navigationBarHidden(true)){
                    Text("進む").padding()
                }
            } else {
                // ユーザー名が登録されている場合はメインページに案内する
                Text("\(loginController.loggedInUserName)さんいらっしゃい！")
                    .onAppear(){
                        print("\(loginController.loggedInUserName)さんいらっしゃい！")
                        print("loginController.loggedInUserName: \(loginController.loggedInUserName)")
                        print("idDidLogin: \(loginController.isDidLogin)")
                        print("isDidLogout: \(loginController.isDidLogout)")
                        
                        // ユーザー情報を全ビュー共通の環境変数に渡す
                        environmentCurrentUserData.uid = loginController.loggedInUserUID!
                        environmentCurrentUserData.email = loginController.loggedInUserEmail!
                        environmentCurrentUserData.userName = loginController.loggedInUserName
                    }
            
                NavigationLink(
                    destination: TabWithAnimationView(
                        currentUser: UserData(uid: loginController.loggedInUserUID!,
                                              email: loginController.loggedInUserEmail!,
                                              userName: loginController.loggedInUserName)
                    )
                    .navigationBarHidden(true)
                ){
                    Text("メインページへ").padding()
                }
                
                Button(action: {
                    loginController.logoutUser(completion: {
                        print("サインアウトしました")
                    })
                }) {
                    Text("ログアウトする")
                }
                NavigationLink(destination: AuthTest(isShowLoginCheckView: $isShowLoginCheckView).navigationBarHidden(false),
                               isActive: $loginController.isDidLogout){
                    EmptyView()
                }
                
            }
        }
        .onAppear(perform: {
            print("DidLoginTestが表示されました")
            isGuestMode.guestModeSwitch = false 
        })
    }
}

//struct DidLoginTest_Previews: PreviewProvider {
//    @ObservedObject var loginController: LoginController
//    
//    static var previews: some View {
//        DidLoginTest()
//    }
//}
