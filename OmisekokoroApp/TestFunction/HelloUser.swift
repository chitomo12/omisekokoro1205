//
//  HelloUser.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/26.
//

import SwiftUI
import Firebase
import FirebaseAuth

// 初めて名前を登録した時に表示されるビュー
struct HelloUser: View {
    @EnvironmentObject var environmentCurrentUserData: UserData
    
    @ObservedObject var currentUserData: UserData
    
    @Binding var currentUserName: String
    
    @State var currentUser: User?
    
    var body: some View {
        Text("初めまして\(currentUserName)さん！")
        
        NavigationLink(
            destination: TabWithAnimationView(
                currentUser: UserData(uid: currentUser?.uid ?? "",
                                      email: currentUser?.email ?? "",
                                      userName: currentUserName)
            )
                .navigationBarHidden(true)){
            Text("メインページへ").padding()
        }
        .onAppear{
            currentUser = Auth.auth().currentUser
            
            environmentCurrentUserData.uid = currentUser!.uid
            environmentCurrentUserData.email = currentUser!.email!
            environmentCurrentUserData.userName = currentUserName
        }
    }
}

struct HelloUser_Previews: PreviewProvider {
//    @ObservedObject var currentUserData = UserData(uid: "sample", email: "sample", userName: <#String#>)
    
    static var previews: some View {
        HelloUser(currentUserData: UserData(uid: "sample", email: "sample@email", userName: "sampleName"), currentUserName: .constant("sample Name"))
    }
}
