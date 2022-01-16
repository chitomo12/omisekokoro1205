//
//  PushNotificationSwiftUIApp.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/04.
//

import SwiftUI
import Firebase

@main
//struct PushNotificationSwiftUIApp: App {
struct OmisekokoroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    @State var isShowLoginCheckView = false
//    @State var fcmToken = "default"
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // 初期画面
            TabWithAnimationView(currentUser: UserData(uid: "sample",
                                                       email: "sample@email.com",
                                                       userName: "sampleName"))
                .environmentObject(UserData(uid: "", email: "", userName: ""))
                .environmentObject(SelectedPost())
                .environmentObject(ShowProgress())
                .environmentObject(FcmToken())
                .environmentObject(IsGuestMode())
                .environmentObject(IsShowPostDetailPopover())
        }
    }
}
