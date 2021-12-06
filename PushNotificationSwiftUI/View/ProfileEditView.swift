//
//  ProfileEditView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI

//struct ProfileEditView: View {
//    @EnvironmentObject var environmentCurrentUserData: UserData
//
//    @ObservedObject var loginController: LoginController
//
//    @Binding var selectedImage: UIImage?
//
//    @State var isShowPHPicker: Bool = false
//    @State var inputText: String = ""
//    @State var isShowLoginCheckView: Bool = false
//    @State var isShowLoginView: Bool = false
//
//    let linearGradientForButton = LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
//
//    var body: some View {
//        NavigationView{
//            VStack{
//                Text("プロフィールを編集")
//
//                // 最初は現在のプロフィール画像を読み込んで表示する。
//                // PHPickerで写真を選択後は選択した画像を表示する。
//                if selectedImage != nil{
//                    Image(uiImage: selectedImage!)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 100, height: 100, alignment: .center)
//                        .cornerRadius(10)
//                        .shadow(color: .gray, radius: 3, x: 0, y: 1)
//                } else {
//                    Image(uiImage: environmentCurrentUserData.profileUIImage!)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 100, height: 100, alignment: .center)
//                        .cornerRadius(10)
//                        .shadow(color: .gray, radius: 3, x: 0, y: 1)
//                }
//
//
//                Button("画像を選択"){
//                    print("画像を選択します")
//                    isShowPHPicker = true
//                }
//
//                // ライブラリから写真を選択ビュー
//                .sheet(isPresented: $isShowPHPicker){
//                    PHPickerView(isShowPHPicker: $isShowPHPicker, selectedImage: $selectedImage)
//                }
//
//                Button("アップロード"){
//                    isShowProgress.progressSwitch = true
//                    print("画像をアップロードします")
//                    if selectedImage != nil{
//                        uploadImageToFirestorage(userUID: environmentCurrentUserData.uid, newImageUIImage: selectedImage!, completion: { _ in
//                            print("アップロード完了")
//                            // プロフィール画像のビューを更新
//                            environmentCurrentUserData.profileUIImage = selectedImage!
//                            isShowProgress.progressSwitch = false
//                        })
//                    } else {
//                        print("選択された画像がありません")
//                        isShowProgress.progressSwitch = false
//                    }
//                }
//
//                TextField("ユーザー名",
//                          text: $inputText,
//                          prompt: Text("ユーザー名を入力してください")
//                )
//                    .onAppear{
//                        inputText = environmentCurrentUserData.userName!
//                    }
//                Button(action: {
//                    print("保存ボタンが押されました")
//                    if inputText != environmentCurrentUserData.userName! {
//                        print("名前を\(environmentCurrentUserData.userName!)から\(inputText)に変更します")
//                        // ユーザー名変更のための処理
//                        environmentCurrentUserData.ChangeUserName(userUID: environmentCurrentUserData.uid, userNewName: inputText, completion: {
//                            environmentCurrentUserData.userName = inputText
//                        })
//                    }
//                }) {
//                    Text("保存")
//                }
//
//                // ログアウトボタン
//                Button(action: {
//                    loginController.logoutUser()
//                    // ユーザー情報をゲスト用に更新
//                    environmentCurrentUserData.uid = "GuestUID"
//                    environmentCurrentUserData.email = "guest@email"
//                    environmentCurrentUserData.userName = "Guest"
//                    environmentCurrentUserData.profileUIImage = UIImage(named: "SampleImage")
//                    // リストを初期化
//                    postedPostCardList = []
//                    bookmarkedPostCardList = []
//                    // 編集画面を閉じる
////                                    isShowEditPopover = false
//                    // ログイン画面へ
//                    isShowLoginView = true
//                }) {
//                    Text("ログアウトする")
//                        .font(.system(size: 15, weight: .bold, design: .rounded))
//                        .foregroundColor(.white)
//                        .frame(width: 180, height: 40, alignment: .center)
//                        .background(linearGradientForButton)
//                        .cornerRadius(20)
//                        .padding()
//                }
//                NavigationLink(destination: AuthTest(loginController: loginController,
//                                                     isShowLoginCheckView: $isShowLoginCheckView,
//                                                     currentUser: environmentCurrentUserData).navigationBarHidden(true),
//                               isActive: $isShowLoginView ){
//                    EmptyView()
//                }
//            }
//        }
//    }
//}

//struct ProfileEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileEditView(environmentCurrentUserData: <#T##EnvironmentObject<UserData>#>, selectedImage: <#T##Binding<UIImage?>#>, isShowPHPicker: <#T##Bool#>, inputText: <#T##String#>)
//    }
//}
