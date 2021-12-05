//
//  AppleLoginTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/25.
//

import SwiftUI
import AuthenticationServices

//struct AppleLoginTest: View {
////    @State var appleAuthResults: Result<ASAuthorization, Error>?
//    @ObservedObject var authViewModel = AuthViewModel()
//
//    var body: some View {
//        Text("Sign In with Apple").bold()
//
//        SignInWithAppleButton(.signIn){ request in
//            request.requestedScopes = [.fullName, .email]
//        } onCompletion: { authResults in
//            authViewModel.appleAuthResults = authResults
//        }
//        .signInWithAppleButtonStyle(.black)
//        .frame(width: 200, height: 45)
//    }
//}
//
//class AuthViewModel: ObservableObject{
//    @Published var appleAuthResults: Result<ASAuthorization, Error>?
//    @Published var disposables: Any?
//
//    init(){
//        $appleAuthResults
//            .sink(receiveValue: { results in
//                switch results {
//                case .success(let authResults):
//                    switch authResults.credential {
//                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
//                        print("userIdentifier:\(appleIDCredential.user)")
//                        print("fullName:\(String(describing: appleIDCredential.fullName))")
//                        print("email:\(String(describing: appleIDCredential.email))")
//                        print("authorizationCode:\(String(describing: appleIDCredential.authorizationCode))")
//
//                        print("ここでログイン処理を呼び出す")
//
//                    default:
//                        break
//                    }
//
//                case .failure(let error):
//                    print(error.localizedDescription)
//
//                default:
//                    break
//                }
//            })
//            .store(in: &disposables)
//        }
//}


//struct AppleLoginTest_Previews: PreviewProvider {
//    @State var appleAuthResults: Result<ASAuthorization, Error>?
//
//    static var previews: some View {
//        AppleLoginTest(appleAuthResults: Result(String, String))
//    }
//}
