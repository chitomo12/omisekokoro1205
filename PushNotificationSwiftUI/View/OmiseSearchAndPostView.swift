//
//  OmiseSearch.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/10/31.
//

import SwiftUI
import MapKit

// Yahoo APIを使った店舗検索ビュー
struct OmiseSearchAndPostView: View {
    @EnvironmentObject var currentUserData: UserData
    
    @ObservedObject var omiseDataList: OmiseData
    @ObservedObject var currentUser: UserData 
    
    @Binding var selectedTag: Int
    @Binding var searchedAndSelectedOmiseLatitude: Double
    @Binding var searchedAndSelectedOmiseLongitude: Double
    @Binding var searchedAndSelectedOmiseName: String
    @Binding var searchedAndSelectedOmiseAddress: String
    @Binding var searchedAndSelectedOmiseImageURL: String?
    @State var searchedAndSelectedOmiseUid: String?
    @Binding var mapSwitch: MapSwitch
    @Binding var isPopover: Bool
    
    @State var searchedAndSelectedOmiseItem: OmiseItem = OmiseItem(name: "選択されていません", coordinates: "", address: "", omiseImage: UIImage(systemName: "house"), omiseImageURL: "", omiseUid: "")
    
    // リストの表示非表示
    @State var isShowingList = false
    
    // リストの高さ（初期値：０）
    @State var listHeight: CGFloat = 0.0
    @State var inputText = ""
    @State var inputComment = ""
    @State var omises: [OmiseItem] = []
    
    // バネアニメーション
    @State var springAnimation: Animation = .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    
    // ローディングマーク
    @State var isListLoading: Bool = false
    @State var listOpacity = 0.0
    
    // ViewControllerからFirebase保存の処理を呼び出す
    var viewController = ViewController()
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(colors: [Color("LightYellow"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
                .ignoresSafeArea()
            
            // キーボードを閉じるためのタップ範囲設定
            Color.white
                .opacity(0.9)
                .contentShape(RoundedRectangle(cornerRadius: 0))  // タップ検出範囲を広げる
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .cornerRadius(20)
                .padding()
            
                    
                VStack(alignment: .leading, spacing: 8.0){
                    HStack{
                        Spacer()
                        Text("新しい投稿を作成")
                                .font(.title)
                                .fontWeight(.ultraLight)
                        Spacer()
                    }
                    
                    HStack{
                        Image(systemName: "house.fill")
                        Text("お店").font(.body).fontWeight(.light)
                    }.padding()
                    
                    TextField("キーワードを入力してお店を検索", text: $inputText, onCommit: {
                        if inputText != "" {
                            // 検索を実行
                            omiseDataList.searchOmise(keyword: inputText)
                            omiseDataList.isNoOmiseFound = false
                            omiseDataList.isListLoading = true
                        }
                        // アニメーション付きでリストに高さを持たせる
                        withAnimation(springAnimation) {
                            isShowingList = true
                            listHeight = 400
                        }
                    })
                        .onTapGesture {
                            closeList()
                        }
                    Rectangle()
                        .frame(height: 2)
                        .padding(.horizontal, 0)
                        .foregroundColor(.gray)
                    
                    // 検索結果一覧
                    ZStack {
                        List(omiseDataList.omiseList) { omise in
                            HStack(alignment: .top) {
                                // 取得した画像、または仮画像を表示する
                                Image(uiImage: omise.omiseImage ?? UIImage(named: "SampleImage")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:90,height: 60)
                                    .clipped()
                                
                                VStack(alignment: .leading) {
                                    Text(omise.name).font(.footnote)
                                    Text(omise.address).font(.caption2).foregroundColor(.gray)
                                }
                            }
                            .opacity(listOpacity)
                            .onAppear(){
                                omiseDataList.isListLoading = false
                                withAnimation(.easeIn(duration: 0.5)){
                                    listOpacity = 1.0
                                }
                            }
                            .padding(.horizontal, 0)
                            .onTapGesture {
                                // 「緯度,経度」の文字列から緯度、経度を取得
                                let omiseLongitudeString = omise.coordinates.components(separatedBy: ",")[0]
                                let omiseLatitudeString = omise.coordinates.components(separatedBy: ",")[1]
                                searchedAndSelectedOmiseItem = omise
                                searchedAndSelectedOmiseLatitude = Double(omiseLatitudeString)!
                                searchedAndSelectedOmiseLongitude = Double(omiseLongitudeString)!
                                searchedAndSelectedOmiseImageURL = omise.omiseImageURL
                                searchedAndSelectedOmiseUid = omise.omiseUid
                                // タップ後にリストを初期化
                                withAnimation(springAnimation) {
                                    omiseDataList.omiseList = []
                                    listHeight = 0
                                }
                            }
                            
                            .listRowBackground(Color.white.opacity(0.5))
                            .cornerRadius(3)
                        }
                        .frame(width: .none, height: listHeight, alignment: .center)
                        .listStyle(.plain)
                        .background(Color.clear)
                        
                        if omiseDataList.isListLoading {
                            ProgressView("")
                        }
                        if omiseDataList.isNoOmiseFound{
                            Text("お店が見つかりませんでした")
                                .onAppear{
                                    withAnimation(springAnimation) {
                                        listHeight = 100
                                    }
                                }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("選択中").font(.caption).fontWeight(.bold)
                        HStack{
                            Image(systemName: "house.fill")
                                .font(.caption)
                                .frame(width: 20, height: 10, alignment: .center)
                            Text("\(searchedAndSelectedOmiseItem.name)")
                                .font(.caption)
                        }
                        HStack{
                            Image(systemName: "map.fill")
                                .font(.caption)
                                .frame(width: 20, height: 10, alignment: .center)
                            Text("\(searchedAndSelectedOmiseItem.address)")
                                .font(.caption2)
                        }
                    }
                    .padding(EdgeInsets(top:15,leading: 35,bottom:0,trailing: 35))
                    .opacity(0.8)
                    
                    HStack{
                        Image(systemName: "bubble.left.fill")
                        Text("どんなお店？").font(.body).fontWeight(.light)
                    }.padding()
                    
                    TextField("コメントを入力", text: $inputComment)
                        .onTapGesture(perform: {
                            closeList()
                        })
                    Rectangle()
                        .frame(height: 2)
                        .padding(.horizontal, 0)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Button(action: {
                            if inputComment.trimmingCharacters(in: .whitespaces).isEmpty != true {
                                print("コメントを送信します")
                                viewController.addPostData(currentUser: currentUserData,
                                                           searchedAndSelectedOmiseItem.name,
                                                           searchedAndSelectedOmiseLatitude,
                                                           searchedAndSelectedOmiseLongitude,
                                                           commentText: inputComment,
                                                           omiseImageURL: searchedAndSelectedOmiseImageURL ?? "",
                                                           searchedAndSelectedOmiseUid: searchedAndSelectedOmiseUid ?? "",
                                                           searchedAndSelectedOmiseItem: searchedAndSelectedOmiseItem,
                                                           completion: { isPopover = false })
                            } else {
                                print("空文字では送信できません")
                            }
                            // 成功したら成功のポップアップを表示（未実装）
                            
                        }) {
                            Text("投稿する")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                                .frame(width: 200, height: 40)
                                .foregroundColor(.white)
                                .background(LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing))
                                .cornerRadius(25)
                                .padding()
                        }.padding()
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 40)
                .edgesIgnoringSafeArea(.all)
            
        }
            
    }
    
    // リストを閉じる関数
    func closeList(){
        if isShowingList == true {
            withAnimation(.easeInOut(duration: 0.5)) {
                isShowingList = false
                listHeight = 0
                listOpacity = 0
            }
        }
    }
}

extension UIApplication {
    // キーボードを隠す
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct OmiseSearchAndPostView_Previews: PreviewProvider {
    
    static var previews: some View {
        OmiseSearchAndPostView(omiseDataList: OmiseData(),
                               currentUser: UserData(uid: "sampleuid",
                                                     email: "sample@email",
                                                     userName: "sampleName"),
                               selectedTag: .constant(1),
                               searchedAndSelectedOmiseLatitude: .constant(0.0),
                               searchedAndSelectedOmiseLongitude: .constant(0.0),
                               searchedAndSelectedOmiseName: .constant("location sample"),
                               searchedAndSelectedOmiseAddress: .constant("sample address"),
                               searchedAndSelectedOmiseImageURL: .constant("sample url"),
                               mapSwitch: .constant(.normal),
                               isPopover: .constant(true))
    }
}
