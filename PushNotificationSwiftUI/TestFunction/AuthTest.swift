//
//  LoginTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/18.
//

import SwiftUI
import Firebase
import FirebaseAuth
import MapKit

struct AuthTest: View {
    @EnvironmentObject var environmentUserData: UserData
    @EnvironmentObject var isGuestMode: IsGuestMode
    
    @ObservedObject var loginController = LoginController()
    
    @Binding var isShowLoginCheckView: Bool
    
    @State var isLoginFailed = false
    @State var createUserEmail = ""
    @State var createUserPassword = ""
    
    @State var isStartGuestMode = false
    
    let linearGradientForButton = LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    // 現在ログイン中のユーザー情報
    @ObservedObject var currentUser = UserData(uid: "default", email: "default", userName: "default")
    
    @State var downloadedUIImageData: Data? = nil
    
    var body: some View {
//        let bounds = UIScreen.main.bounds
//        let screenWidth = bounds.width
        
        NavigationView{
            ZStack {
                VStack{
                    Image("omisekokoroLogo")
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                        .scaledToFill()
                        .padding(.top, 80)
                    
                    // ログインしている場合、ログイン中のユーザー情報を表示
                    if let authCurrentUser = Auth.auth().currentUser,
                       environmentUserData.userName != nil,
                       loginController.isSentVerificationEmail == false {
                        VStack{
                            // ログイン中のユーザー情報(Environment)
                            Text("\(environmentUserData.userName!)でログインしました").padding()
                            
                            Button(action: {
                                isShowLoginCheckView = false
                            }){
                                RedButtonView(buttonText: "メインページへ")
                            }
                            
                            // ログアウトボタン
                            Button(action: {
                                loginController.logoutUser(completion: {
                                    print("サインアウトしました")
                                })
                                currentUser.uid = ""
                                currentUser.email = ""
                            }) {
                                RedButtonView(buttonText: "ログアウトする")
                            }
                        }
                        .onAppear{
                            loginController.isDidLogout = false
                            
                            // EnvironmentObject
                            print("environmentUserData.uid: \(authCurrentUser.uid)")
                            environmentUserData.uid = authCurrentUser.uid
                            environmentUserData.email = authCurrentUser.email ?? ""
                            getUserImageFromFirestorage(userUID: authCurrentUser.uid, completion: { data in
                                if data != nil {
                                    print("プロフィール画像を読み込みます：\(data!)")
                                    environmentUserData.profileUIImage = UIImage(data: data!)
                                } else {
                                    print("プロフィール画像が見つかりません")
                                    environmentUserData.profileUIImage = UIImage(named: "SampleImage")
                                }
                            })
                            
                            // ObservedObject
                            currentUser.uid = authCurrentUser.uid
                            currentUser.email = authCurrentUser.email ?? ""
                            
                            // UIDでFirestoreからユーザー名を取得する
                            loginController.getUserNameFromUid(
                                userUid: authCurrentUser.uid,
                                completion: { userNameString in
                                    print("ユーザー名: \(String(describing: userNameString)) を取得しました。")
                                    environmentUserData.userName = userNameString
                                    currentUser.userName = userNameString
                            })
                            
                            // ゲストモードを解除
                            isGuestMode.guestModeSwitch = false
                        }
                    } else {
                        
                        // ログインしていない場合、ログインまたは新規登録のビューを表示する
                        
                        // 認証メール送信後はメッセージを表示
//                        if loginController.isSentVerificationEmailMessage.isEmpty == false {
                            Text("\(loginController.isSentVerificationEmailMessage)")
//                        }
                        
                        // 新規登録画面へ
                        NavigationLink(destination: RegisterView(loginController: loginController),
                                       label: {
                            RedButtonView(buttonText: "新規登録")
                        })
                        
                        
                        NavigationLink(destination: LoginTest(currentUser: currentUser,
                                                              isShowLoginCheckView: $isShowLoginCheckView)
                        ){
                            RedButtonView(buttonText: "ログイン")
                        }
                        
                        
                        Button(action: {
                            environmentUserData.uid = "Guest UID"
                            environmentUserData.email = "guest@email"
                            environmentUserData.userName = "Guest"
                            isStartGuestMode = true
                            isShowLoginCheckView = false
                        }) {
                            Text("ゲストモードでログイン")
                                .padding()
                        }
                        .onAppear {
                            // Async/Awaitのテスト
                            Task {
                                let num = await countSummary()
                                print("count=",num)
                                print("countSummary end")
                                let postList = await getPostListFromAllAsyncTest()
                                print("postList: \(postList!.count)")
                                print("postList: \(postList!)")
                            }
                        }
                    }
                Spacer()
                }
            }
            .onAppear(perform: {
                print("AuthTestが表示されました")
            })
        }.navigationBarHidden(true)
    }
    
    // Async/Awaitのテスト
    @State var count = 0
    func countSummary() async -> Int {
        let a = await countUp(num: 1)
        let b = await countUp(num: 2)
        let c = await countUp(num: 3)
        let d = await countUp(num: 4)
        print("SUM=", a + b + c + d )
        return count
    }
     
    func countUp(num:Int) async -> Int {
        let interval  = TimeInterval(arc4random() % 100 + 1) / 100
        Thread.sleep(forTimeInterval: interval)
        count += num
        print("num=",num)
        print("count=",count)
        return count
    }
    
    @State var postCardList: [PostForCard] = []
    func getPostListFromAllAsyncTest() async -> [PostForCard]? {
        // リストを初期化
        postCardList.removeAll()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        
        // Firestoreのセッティング
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let snapShot = try? await db.collection("locationCollection")
            .document("locationDocument")
            .collection("subLocCollection")
            .order(by: "created_at", descending: true)  // 日付降順で取得
            .limit(to: 10)
            .getDocuments()
        
        return snapShot?.documents.map({ document -> PostForCard in
            
            let postName = String(describing: document.get("name")! )
            let postCreatedAt = document.get("created_at") as! Timestamp
            let postCreatedAtDate = postCreatedAt.dateValue()
            let postCreatedAtString = formatter.string(from: postCreatedAtDate)
            let postComment = String(describing: document.get("comment")! )
            let postLatitude = document.get("latitude") as! Double
            let postLongitude = document.get("longitude") as! Double
            
            // カード用の構造体postCardListにデータを格納
            //   Postのリストとの違いはUIImageのプロパティがあること。
            var postImageUIImage: UIImage? = UIImage(named: "SampleImage")
            
            // オプショナルバインディング
            if let tempImageURL = URL(string: document.get("imageURL") as! String){
                print("次のURLから画像を読み込みます: \(tempImageURL)")
                do {
                    let tempImageData = try Data(contentsOf: tempImageURL)
                    postImageUIImage = UIImage(data: tempImageData)
                    print("画像を読み込みました")
                } catch {
                    print("画像の読み込みに失敗")
                }
            } else {
                print("tempImageDataURLURL is nil")
            }
            
            // 投稿者のプロフィール画像を取得
            var userImageUIImage = UIImage(systemName: "person")
            
            getUserImageFromFirestorage(userUID: document.get("postUserUID") as! String) { data in
                if data != nil {
                    print("投稿者画像を読み込みました：\(data!)")
                    userImageUIImage = UIImage(data: data!)
                } else {
                    print("投稿者画像が見つかりません")
                }
//                postCardList.append(
//                )
//                print("ドキュメントを追加しました")
//                // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
//                postCardList = postCardList.sorted(by: { (a,b) -> Bool in
//                    return a.created_at > b.created_at
//                })
            }
            
            return PostForCard(omiseName: postName,
                        documentId: document.documentID,
                        created_at: postCreatedAtString,
                        comment: postComment,
                        coordinate: CLLocationCoordinate2D(latitude: postLatitude,
                                                           longitude: postLongitude),
                        created_by: document.get("postUserUID") as! String?,
                        created_by_name: document.get("postUserName") as! String?,
                        imageURL: document.get("imageURL") as! String?,
                        imageUIImage: postImageUIImage,
                        userImageUIImage: userImageUIImage!)
        })
        
//        { (querySnapshot, error) in
//                for document in querySnapshot!.documents {
//                    let postName = String(describing: document.get("name")! )
//                    let postCreatedAt = document.get("created_at") as! Timestamp
//                    let postCreatedAtDate = postCreatedAt.dateValue()
//                    let postCreatedAtString = formatter.string(from: postCreatedAtDate)
//                    let postComment = String(describing: document.get("comment")! )
//                    let postLatitude = document.get("latitude") as! Double
//                    let postLongitude = document.get("longitude") as! Double
//
//                    // カード用の構造体postCardListにデータを格納
//                    //   Postのリストとの違いはUIImageのプロパティがあること。
//                    var postImageUIImage: UIImage? = UIImage(named: "SampleImage")
//
//                    // オプショナルバインディング
//                    if let tempImageURL = URL(string: document.get("imageURL") as! String){
//                        print("次のURLから画像を読み込みます: \(tempImageURL)")
//                        do {
//                            let tempImageData = try Data(contentsOf: tempImageURL)
//                            postImageUIImage = UIImage(data: tempImageData)
//                            print("画像を読み込みました")
//                        } catch {
//                            print("画像の読み込みに失敗")
//                        }
//                    } else {
//                        print("tempImageDataURLURL is nil")
//                    }
//
//                    // 投稿者のプロフィール画像を取得
//                    var userImageUIImage = UIImage(systemName: "person")
//                    getUserImageFromFirestorage(userUID: document.get("postUserUID") as! String) { data in
//                        if data != nil {
//                            print("投稿者画像を読み込みました：\(data!)")
//                            userImageUIImage = UIImage(data: data!)
//                        } else {
//                            print("投稿者画像が見つかりません")
//                        }
//                        postCardList.append(
//                            PostForCard(omiseName: postName,
//                                 documentId: document.documentID,
//                                 created_at: postCreatedAtString,
//                                 comment: postComment,
//                                 coordinate: CLLocationCoordinate2D(latitude: postLatitude,
//                                                                    longitude: postLongitude),
//                                 created_by: document.get("postUserUID") as! String?,
//                                 created_by_name: document.get("postUserName") as! String?,
//                                 imageURL: document.get("imageURL") as! String?,
//                                 imageUIImage: postImageUIImage,
//                                 userImageUIImage: userImageUIImage!
//                                )
//                        )
//                        print("ドキュメントを追加しました")
//                        // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
//                        postCardList = postCardList.sorted(by: { (a,b) -> Bool in
//                            return a.created_at > b.created_at
//                        })
//                    }
//                }
//                if error != nil {
//                    print("error: \(String(describing: error))")
//                }
//            }
//        return postCardList
    } // getPostListFromAllここまで
}

struct AuthTest_Previews: PreviewProvider {
//    @ObservedObject var loginController: LoginController
    
    static var previews: some View {
        AuthTest(isShowLoginCheckView: .constant(true))
    }
}
