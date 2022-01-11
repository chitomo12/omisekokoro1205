//
//  OmiseSearch.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/10/31.
//

import SwiftUI
import MapKit

// Yahoo APIを使った店舗検索のためのビュー
struct OmiseSearchAndPostView: View {
    @EnvironmentObject var currentUserData: UserData
    
    @ObservedObject var omiseDataList: OmiseData
//    @ObservedObject var currentUser: UserData
    
    @Binding var selectedTag: Int
    @Binding var searchedAndSelectedOmiseLatitude: Double
    @Binding var searchedAndSelectedOmiseLongitude: Double
//    @Binding var searchedAndSelectedOmiseName: String
    @Binding var searchedAndSelectedOmiseAddress: String
    @Binding var searchedAndSelectedOmiseImageURL: String?
    @State var searchedAndSelectedOmiseImage: UIImage? = UIImage(named: "SampleImage")
    @State var searchedAndSelectedOmiseUid: String?
    @State var isSomeOmiseSelected: Bool = false
    @Binding var mapSwitch: MapSwitch
    @Binding var isPopover: Bool
    @Binding var mkMapView: MKMapView
    
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
    
    @State var postData = PostData()
    
    @State var isShowingAlert: Bool = false
    @State var alertMessage: String = ""
    
    @State var postedOmiseCoordinate: CLLocationCoordinate2D?
    
    // ViewControllerからFirebase保存の処理を呼び出す
    var viewController = ViewController()
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        
        ZStack {
            // 背景
            LinearGradient(colors: [Color("LightYellow"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
                .ignoresSafeArea()
            
            // キーボードを閉じるためのタップ領域設定
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
                                searchedAndSelectedOmiseImage = omise.omiseImage
                                searchedAndSelectedOmiseUid = omise.omiseUid
                                isSomeOmiseSelected = true
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
                    
                    VStack(alignment: .center, spacing: 8) {
                        Text("選択中").font(.caption).fontWeight(.bold)
                        HStack{
                            Image(uiImage: searchedAndSelectedOmiseImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 48, alignment: .center)
                                .clipped()
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
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
                        }
                    }
                    .padding(EdgeInsets(top:15,leading: 0,bottom:0,trailing: 0))
                    .frame(width: bounds.width - 120 )
                    
                    HStack{
                        Image(systemName: "bubble.left.fill")
                        Text("どんなお店？").font(.body).fontWeight(.light)
                    }.padding()
                    
                    TextField("コメントを入力（100文字以内）", text: $inputComment)
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
                            if isSomeOmiseSelected == false {
                                alertMessage = "お店を未選択、または空文字では送信できません"
                                isShowingAlert = true
                            } else if inputComment.trimmingCharacters(in: .whitespaces).isEmpty == true {
                                alertMessage = "投稿文がありません"
                                isShowingAlert = true
                            } else if inputComment.trimmingCharacters(in: .whitespaces).count >= 100 {
                                alertMessage = "投稿文の文字制限は100文字までです"
                                isShowingAlert = true
                            } else {
                                // エラーがなければ
                                print("コメントを送信します")
                                
                                postData.addPostDataFromModel(currentUser: currentUserData,
                                                              searchedAndSelectedOmiseItem.name,
                                                              searchedAndSelectedOmiseLatitude,
                                                              searchedAndSelectedOmiseLongitude,
                                                              commentText: inputComment,
                                                              omiseImageURL: searchedAndSelectedOmiseImageURL ?? "",
                                                              searchedAndSelectedOmiseUid: searchedAndSelectedOmiseUid ?? "",
                                                              searchedAndSelectedOmiseItem: searchedAndSelectedOmiseItem,
                                                              completion: {
                                    alertMessage = "投稿しました"
                                    isShowingAlert = true
                                    // 投稿完了後、MapViewのフォーカスを投稿した吹き出しの座標に移す
                                })
//                                isShowingAlert = true
                            }
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
                        
                        // アラート
                            .alert("確認", isPresented: $isShowingAlert) {
                                Button("OK"){
                                    if alertMessage == "投稿しました"{
                                        // 投稿完了の場合、投稿画面を閉じてフォーカスを移す
                                        moveFocus(
                                            mapView: mkMapView,
                                            targetCoordinate: CLLocationCoordinate2D(
                                                latitude: searchedAndSelectedOmiseLatitude,
                                                longitude: searchedAndSelectedOmiseLongitude
                                            )
                                        )
                                        isPopover = false
                                    }
                                }
                            } message: {
                                Text(alertMessage)
                            }
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

// mapViewのフォーカスを移動させる関数
func moveFocus(mapView: MKMapView, targetCoordinate: CLLocationCoordinate2D) {
    print("次の座標に焦点を移します : \(targetCoordinate)")
    mapView.setRegion(MKCoordinateRegion(center: targetCoordinate,
                                         span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)),
                        animated: false)
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
                               selectedTag: .constant(1),
                               searchedAndSelectedOmiseLatitude: .constant(0.0),
                               searchedAndSelectedOmiseLongitude: .constant(0.0),
                               searchedAndSelectedOmiseAddress: .constant("sample address"),
                               searchedAndSelectedOmiseImageURL: .constant("sample url"),
                               mapSwitch: .constant(.normal),
                               isPopover: .constant(true),
                               mkMapView: .constant(MKMapView()))
    }
}
