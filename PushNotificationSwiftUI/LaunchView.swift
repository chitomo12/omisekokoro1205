//
//  LaunchView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/30.
//

import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    @EnvironmentObject var environmentCurrentUser: UserData
    
    @ObservedObject var loginController = LoginController()
    
    @Binding var isShowLoginCheckView: Bool
    
    @State var currentUserName: String? = ""
    
    @State var goToMainPageSwitch = false
    @State var goToAuthTestSwitch = false
    
    var body: some View {
        NavigationView{
            VStack{
                Image("omisekokoroLogo")
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                    .scaledToFill()
                    .padding(.top, 100)
                ProgressView("Loading")
            }
            .onAppear{
                // ログイン中かどうか判定。
                //  - ログイン中 → メインページへ
                //  - ログアウト中 → 新規登録＆ログインページ（AuthTest）へ
                if let authCurrentUser = Auth.auth().currentUser {
                    print("ログイン中です")
                    loginController.getUserNameFromUid(userUid: authCurrentUser.uid, completion: { result in
                        currentUserName = result
                        environmentCurrentUser.uid = authCurrentUser.uid
                        environmentCurrentUser.email = authCurrentUser.email!
                        environmentCurrentUser.userName = currentUserName!
                        getUserImageFromFirestorage(userUID: authCurrentUser.uid, completion: { data in
                            if data != nil {
                                environmentCurrentUser.profileUIImage = UIImage(data: data!)
                            }
                            goToMainPageSwitch = true
                        })
                    })
                } else {
                    print("ログアウト中です")
                    goToAuthTestSwitch = true
                }
            }
            
            NavigationLink(destination: TabWithAnimationView(currentUser: environmentCurrentUser)
                            .navigationBarHidden(true),
                           isActive: $goToMainPageSwitch){
                EmptyView()
            }

            NavigationLink(destination: AuthTest(isShowLoginCheckView: $isShowLoginCheckView)
                            .navigationBarHidden(true),
                           isActive: $goToAuthTestSwitch){
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(isShowLoginCheckView: .constant(true))
    }
}
