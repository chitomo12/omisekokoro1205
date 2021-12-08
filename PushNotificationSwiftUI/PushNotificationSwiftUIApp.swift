//
//  PushNotificationSwiftUIApp.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/04.
//

import SwiftUI
import Firebase

@main
struct PushNotificationSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    @State var isShowLoginCheckView = false
    @State var fcmToken = "aaa"
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // Last Goal
            TabWithAnimationView(currentUser: UserData(uid: "sample",
                                                       email: "sample@email.com",
                                                       userName: "sampleName"))
                .environmentObject(UserData(uid: "", email: "", userName: ""))
                .environmentObject(SelectedPost())
                .environmentObject(ShowProgress())
                .environmentObject(FcmToken())
                .environmentObject(IsGuestMode())
                .environmentObject(IsShowPostDetailPopover())
                .environmentObject(PostForCardClass())
            
            //            ContentView()
            
//            AuthTest(isShowLoginCheckView: $isShowLoginCheckView,
//                     currentUser: UserData(uid: "sample", email: "sample@email.com", userName: "sampleName"))
//
//                .environmentObject(UserData(uid: "", email: "", userName: ""))
//                .environmentObject(SelectedPost())
//                .environmentObject(ShowProgress())
        }
    }
}
