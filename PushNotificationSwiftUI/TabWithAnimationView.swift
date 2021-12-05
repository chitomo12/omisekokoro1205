//
//  AnimationTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/13.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct TabWithAnimationView: View {
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var environmentFcmToken: FcmToken
    
    @ObservedObject var omiseDataList = OmiseData()
    @ObservedObject var postData = PostData()
    @ObservedObject var currentUser: UserData
    
    // ログイン状態の管理
    @State var loggedInUserName: String = ""
    @State var loggedInUserEmail: String = ""
    
    @State var selectedTag = 1
    
    @State var latitude: Double = 0.0
    @State var longitude: Double = 0.0
    @State var searchedLocationName: String = "default"
    @State var searchedAddress: String = ""
    @State var mapSwitch: MapSwitch = .initialized
    
    // 円の半径
    @State var circleRadius: CGFloat = 30
    @State var circleDefaultLocX: CGFloat = .zero
    @State private var circleOffsetX: CGFloat = .zero
    @State var circleColorNow = Color(red: 1, green: 0.5, blue: 0.5)
    @State var springAnimation: Animation = .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    @State var colorOfSelectedIcon = Color(red: 1, green: 0.5, blue: 0.5)
    @State var colorOfNonSelectedIcon = Color(red:1, green:0, blue:0)
    @State var colorOfIconOne = Color(red: 1, green: 0.5, blue: 0.5)
        
    @State var iconsLocX: [CGFloat] = [0,0,0,0,0]
    @State var circleColorOne = Color("ColorOne")
    @State var circleColorTwo = Color(red: 217/255, green: 83/255, blue: 79/255)
    @State var circleColorThree = Color(red: 150/255, green: 206/255, blue: 180/255)
    @State var circleColorFour = Color(red: 255/255, green: 173/255, blue: 96/255)
    @State var circleColors: [Color] = [.white,
                                        Color("ColorOne"),
                                        Color("ColorTwo"),
                                        Color("ColorThree"),
                                        Color("ColorFour")]
    @State var IconColors: [Color] = [.white, .white, Color("ColorOne"), Color("ColorOne"), Color("ColorOne")]
    @State var linearGradientNow = LinearGradient(gradient: Gradient(colors: [.green, .blue]),
                                                 startPoint: .top,
                                                 endPoint: .bottom)
    @State var linearGradientA = LinearGradient(gradient: Gradient(colors: [.red, .green]),
                                                 startPoint: .top,
                                                endPoint: .bottom)
    @State var linearGradientB = LinearGradient(gradient: Gradient(colors: [.blue, .red]),
                                                 startPoint: .top,
                                                endPoint: .bottom)
    
    // アイコンのアニメーション
    @State var slowSpringAnimation: Animation = .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)
    @State var rotationOne = false
    @State var rotationTwo = false
    @State var rotationThree = false
    @State var rotationFour = false
        
    var body: some View {
        ZStack{
            VStack{
                // コンテンツ表示コーナー
                TabView(selection: $selectedTag) {
                    MapAndSearch(currentUser: currentUser,
                                 searchedLocationName: $searchedLocationName,
                                 searchedAddress: $searchedAddress,
                                 mapSwitch: $mapSwitch)
                        .tabItem{}.tag(1)
                    
                    FeatureViewDesign()
                        .tabItem{}.tag(2)
                    
                    MyPageDesignView(currentUser: currentUser, mapSwitch: $mapSwitch)
                        .tabItem{}.tag(3)
                    
                    CommentListView(mapSwitch: $mapSwitch)
                        .tabItem{}.tag(4)
                }
                .tabViewStyle(PageTabViewStyle())
                .animation(.default, value: selectedTag)
                .edgesIgnoringSafeArea(.top)
                
                // タブ選択コーナー
                ZStack (alignment: .center){
                    // アイコン間を動く円
                    GeometryReader { geo in
                        
                        Circle()
                            .frame(width: circleRadius * 2, height: circleRadius * 2)
                            .shadow(color: circleColors[selectedTag], radius:2,x:0,y:3)
                            .offset(x: circleOffsetX, y: 30-circleRadius)
                            .foregroundColor(circleColors[selectedTag])
                            .onAppear{
                                // NavigationLinkの描画ラグ対策のため、時差を置いて値を設定する
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    if circleDefaultLocX == .zero {
                                        circleDefaultLocX = geo.frame(in: .global).minX
                                        print("circleDefaultLocX: \(circleDefaultLocX)")
                                    }
                                }
                            }
                        
                    }
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    
                    HStack {
                        GeometryReader { geo in
                            tabButtonIconViewModel(imageName: "globe.asia.australia", iconName: "Omise")
                                .rotationEffect(Angle.degrees(rotationOne ? 0 : 360))
                                .foregroundColor(IconColors[1])
                                .onAppear {
                                    // 初回表示時のみ丸の位置を初期化
                                    if circleOffsetX == .zero {
                                        circleOffsetX = geo.frame(in: .local).midX - circleRadius
    //                                    circleDefaultLocX = circleOffsetX
                                    }
                                }
                                .onChange(of: selectedTag) { value in
                                    // 最初にselectedTagが変わるタイミングでビューの座標を取得
                                    iconsLocX[1] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    iconsLocX[1] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                    moveCircle(selectedIcon: 1)
                                    withAnimation(slowSpringAnimation){
                                        rotationOne.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        GeometryReader{ geo in
                            tabButtonIconViewModel(imageName: "magnifyingglass", iconName: "Search")
                                .foregroundColor(IconColors[2])
                                .rotationEffect(Angle.degrees(rotationTwo ? 0 : 360))
                                .onChange(of: selectedTag) { value in
                                    // 最初にselectedTagが変わるタイミングでビューの座標を取得
                                    iconsLocX[2] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    moveCircle(selectedIcon: 2)
                                    withAnimation(slowSpringAnimation){
                                        rotationTwo.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        GeometryReader{ geo in
                            tabButtonIconViewModel(imageName: "person", iconName: "My Page")
                                .foregroundColor(IconColors[3])
                                .rotationEffect(Angle.degrees(rotationThree ? 0 : 360))
                                .onChange(of: selectedTag) { value in
                                    iconsLocX[3] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    moveCircle(selectedIcon: 3)
                                    withAnimation(slowSpringAnimation){
                                        rotationThree.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        GeometryReader{ geo in
                            tabButtonIconViewModel(imageName: "envelope", iconName: "Info")
                                .foregroundColor(IconColors[4])
                                .rotationEffect(Angle.degrees(rotationFour ? 0 : 360))
                                .onChange(of: selectedTag) { value in
                                    iconsLocX[4] = geo.frame(in: .global).minX + geo.frame(in: .local).midX - circleRadius - circleDefaultLocX
                                }
                                .onTapGesture {
                                    moveCircle(selectedIcon: 4)
                                    withAnimation(slowSpringAnimation){
                                        rotationFour.toggle()
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } // HStackここまで
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .onChange(of: selectedTag){ newValue in
                    moveCircle(selectedIcon: newValue)
                }
                .padding(.bottom)
                // ZStackここまで
            }
            .padding(.bottom)

            .background(LinearGradient(gradient: Gradient(colors: [.white, circleColorNow]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .opacity(0.1))
            .edgesIgnoringSafeArea(.bottom)
            .onAppear{
                if let user = Auth.auth().currentUser {
                    print("user.uid: \(user.uid)")
                    print("user.email: \(user.email ?? "")")
                    loggedInUserName = user.email ?? ""
                    loggedInUserEmail = user.email ?? ""
                    print("self!.loggedInUserName: \(loggedInUserName)")
                }
            }
            
            // ロード中表示
            if isShowProgress.progressSwitch {
                ProgressView("Loading")
                    .frame(width:100, height:120, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(10)
                    .opacity(0.95)
            }
        }
    }
    
    // Circleを動かすためのビュー固有関数
    public func moveCircle(selectedIcon: Int){
        selectedTag = selectedIcon
        withAnimation(springAnimation){
            circleOffsetX = iconsLocX[selectedIcon]
            circleColorNow = circleColors[selectedIcon]
        }
        (0..<IconColors.count).forEach{ IconColors[$0] = circleColorNow }
        IconColors[selectedIcon] = .white
    }
}

struct tabButtonIconViewModel: View{
    var imageName: String
    var iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
            .frame(width: 20, height: 20)
            Text(iconName)
                .font(.caption2)
                .fontWeight(.bold)
        }
    }
}

struct AnimationTest_Previews: PreviewProvider {
    static var previews: some View {
        TabWithAnimationView(currentUser: UserData(uid: "sample", email: "sample@email.com", userName: "sampleName"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
    }
}
