//
//  SearchDesign.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit

// 最新の投稿リストを表示するビュー
struct LatestPostsListView: View {
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var isShowPostDetailPopover: IsShowPostDetailPopover
    
    @ObservedObject var latestPosts = PostData()
    
    @State var postList: [Post] = []
    
    @State var postCardList: [PostForCard] = []
    
    // 投稿詳細ポップオーバー表示用のブーリアン（trueでポップオーバーが表示される）
    @State var isShowingDetailPopover: Bool = false
    // 投稿詳細コンテンツ表示用のブーリアン
    @State var isShowingDetailContent: Bool = false
    
    @State var lastAddedPostTimestamp: Timestamp = Timestamp(date: Date())
    
    var body: some View {
        ScrollView{
            Button(action: {
                postCardList = [] // 初期化
                latestPosts.getTenPostsFromAll(completion: { value, timestamp in
                    postCardList.append(value)
                    lastAddedPostTimestamp = timestamp
                    // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                    postCardList = postCardList.sorted(by: { (a,b) -> Bool in
                        isShowProgress.progressSwitch = false
                        return a.created_at > b.created_at
                    })
                })
            }) {
                Text("コメント取得")
            }
            .padding(.top, 50)
            
            VStack {
                ForEach(0..<postCardList.count, id: \.self) { count in
                    // 投稿をリスト化して表示
                    PostCardViewTwo(post: $postCardList[count])
                }
                Button(action: {
                    print("さらに読み込みます")
//                    getTenMorePostsFromAll()
                    latestPosts.getTenMorePosts(lastAddedPostTimestamp: lastAddedPostTimestamp, completion: { value, timestamp in
                        postCardList.append(value)
                        lastAddedPostTimestamp = timestamp
                        // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                        postCardList = postCardList.sorted(by: { (a,b) -> Bool in
                            return a.created_at > b.created_at
                        })
                    })
                }) {
                    Text("さらに読み込む").padding(EdgeInsets(top: 30, leading: 0, bottom: 100, trailing: 0))
                }
            }
            .onAppear(){
                if postCardList.count >= 1 {
                    print("投稿一覧は読み込み済みです")
                } else {
                    // Loadingを表示
                    isShowProgress.progressSwitch = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        getPostListFromAll()
                        latestPosts.getTenPostsFromAll(completion: { value, timestamp in
                            postCardList.append(value)
                            lastAddedPostTimestamp = timestamp
                            // 非同期で順次読み込まれるため、リストに要素を追加するごとに並び替えを行う
                            postCardList = postCardList.sorted(by: { (a,b) -> Bool in
                                isShowProgress.progressSwitch = false
                                return a.created_at > b.created_at
                            })
                        })
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        LatestPostsListView()
    }
}
