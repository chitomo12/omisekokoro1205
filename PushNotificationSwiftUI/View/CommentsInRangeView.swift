//
//  CommentsInRangeView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/09.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GeoFire

struct CommentsInRangeView: View {
    @ObservedObject var postData: PostData
    
    @Binding var mapSwitch: MapSwitch
    
    @State var postList: [Post] = []
    let centerTokyo = CLLocationCoordinate2D(latitude: 35.65859206, longitude: 139.74544113)
    let radiusInM: Double = 50 * 1000
    
    var body: some View {
        VStack {
            Button(action: {
                postData.postList = [] // 初期化
                print("データを取得します...")
                // データを取得
                postData.getPostListAround(givenCenter: centerTokyo,
                                           radius: radiusInM,
                                           completion: {result in
                    print("finish getPostListAround")
                })
                print("postList: \(postList)")
            }) {
                Text("東京から50km以内のコメントを取得")
            }
            List(postData.postList){ post in
                VStack(alignment: .leading){
                    Text(post.omiseName).font(.caption)
                    Text(post.comment)
                    Text(post.created_at).font(.caption)
                }
            }
        }
    }
} // struct CommentsInRangeView: Viewここまで

struct CommentsInRangeView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsInRangeView(postData: PostData(), mapSwitch: .constant(.normal))
    }
}
