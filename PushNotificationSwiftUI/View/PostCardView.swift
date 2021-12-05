//
//  PostCardView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/26.
//

import SwiftUI
import MapKit

struct PostCardView: View {
    @Binding var post: PostForCard
    
    @State var postImageUIImage: UIImage = UIImage(named: "emmy")!
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let screenWidth = bounds.width
        
        VStack(alignment: .leading) {
            HStack {
                Image(uiImage: post.userImageUIImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                Text(post.created_by_name ?? "Guest").font(.caption)
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
            HStack(alignment: .top) {
                Image(uiImage: post.imageUIImage!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: (screenWidth / 5), height: (screenWidth / 6))
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 5))
                VStack(alignment: .leading){
                    Text(post.omiseName)
                        .fontWeight(.medium)
                        .padding(.bottom, 1)
                    Text(post.comment)
                        .font(.caption)
                        .frame(width:(screenWidth / (3 / 2)) - 10, alignment: .leading)
                        .padding(.bottom, 5)
                    Spacer().frame(height: 10)
                    Text(post.created_at)
                        .font(.caption2)
                    Spacer().frame(height: 15)
                }
                .padding(.trailing, 10)
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.gray.opacity(0.2), radius: 1, x: 0, y: 3)
        .padding(EdgeInsets(top: 3, leading: 20, bottom: 3, trailing: 20))
        .onAppear {
            // CardViewが表示されたらプロフィールとお店の画像を読み込み開始。
            //  → PostCardViewTwo に移行
        }
    }
}

struct PostCardViewTwo: View {
    @Binding var post: PostForCard
    
    @State var loadingUserImage: Bool = true
    @State var postUserImageUIImage: UIImage = UIImage(systemName: "person")!
    @State var postOmiseImageUIImage: UIImage = UIImage(named: "SampleImage")!
    
    @State var hasBeenInitialized = false
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let screenWidth = bounds.width
        
        VStack(alignment: .leading) {
            HStack {
                Image(uiImage: postUserImageUIImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                Text(post.created_by_name ?? "Guest").font(.caption)
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
            HStack(alignment: .top) {
                Image(uiImage: postOmiseImageUIImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: (screenWidth / 5), height: (screenWidth / 6))
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 5))
                VStack(alignment: .leading){
                    Text(post.omiseName)
                        .fontWeight(.medium)
                        .padding(.bottom, 1)
                    Text(post.comment)
                        .font(.caption)
                        .frame(width:(screenWidth / (3 / 2)) - 10, alignment: .leading)
                        .padding(.bottom, 5)
                    Spacer().frame(height: 10)
                    Text(post.created_at)
                        .font(.caption2)
                    Spacer().frame(height: 15)
                }
                .padding(.trailing, 10)
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.gray.opacity(0.2), radius: 1, x: 0, y: 3)
        .padding(EdgeInsets(top: 3, leading: 20, bottom: 3, trailing: 20))
        .onAppear {
            // 最初に表示された時にのみ実行
            if hasBeenInitialized == false {
                // CardViewが表示されたらプロフィールとお店の画像を読み込み開始。
                
                // 投稿者のプロフィール画像を読み込み
                getUserImageFromFirestorage(userUID: post.created_by ?? "GuestUID", completion: { data in
                    if data != nil{
                        postUserImageUIImage = UIImage(data: data!)!
                    } else {
                        postUserImageUIImage = UIImage(named: "SampleImage")!
                    }
                })
                
                // お店画像の読み込み
                getImageFromURL(urlString: post.imageURL, completion: {uiImage in
                    postOmiseImageUIImage = uiImage
                })
                
                hasBeenInitialized = true
            }
        }
    }
}

struct PostCardView_Previews: PreviewProvider {
    static var previews: some View {
        PostCardView(post: .constant(PostForCard(omiseName: "sampleOmiseName",
                                          documentId: "sampleID",
                                          created_at: "2000年11月22日",
                                          comment: "サンプルコメント",
                                          coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                          created_by: "サンプルユーザー",
                                          created_by_name: "sample name",
                                          imageURL: "sample URL",
                                          imageUIImage: UIImage(named: "emmy")!,
                                          userImageUIImage: UIImage(systemName: "person")!)
                                    ),
                     postImageUIImage: UIImage(named: "emmy")!
        )
    }
}