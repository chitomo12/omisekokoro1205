//
//  FirestorageTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/29.
//

import SwiftUI
//import Firebase
import FirebaseStorage

struct FirestorageTest: View {
    @EnvironmentObject var currentUser: UserData
    
    @State var imageURL: URL? = URL(string: "no URL")
    
    var body: some View {
        Text("URL: \(imageURL!.absoluteString)")
        Button("アップロード"){
            print("画像をアップロードします")
            uploadImageToFirestorage(userUID: currentUser.uid, newImageUIImage: UIImage(systemName: "house")!, completion: { downloadURL in
                // アップロード後、ダウンロードURLから画像を再取得してビューに反映する
                imageURL = downloadURL
            })
        }
    }
}

func uploadImageToFirestorage(userUID: String, newImageUIImage: UIImage, completion: @escaping (URL?)->() ) {
    
    let storage = Storage.storage()
    let storageRef = storage.reference()
    var data = Data()
//    data = UIImage(named:"emmy")!.jpegData(compressionQuality: 0.1)!
    data = newImageUIImage.jpegData(compressionQuality: 0.1)!
    let riversRef = storageRef.child("images/\(userUID).jpg")
    let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, nil) in
        print(String(describing: metadata))
        guard let metadata = metadata else {
            print("some error in metadata")
            // some errors
            return
        }
        let size = metadata.size
        riversRef.downloadURL{ (url, error) in
            print("DL URL: \(String(describing: url))")
            guard let downloadURL = url else {
                // some error
                print("some error in downloadURL")
                return
            }
            completion(url)
        }
    }
}

func getUserImageFromFirestorage(userUID: String, completion: @escaping (Data?) -> () ){
    print("\(userUID)から画像ファイルをダウンロードします")
    // downloadURLから画像ファイルをダウンロードするメソッド
    let storage = Storage.storage()
    let imageRef = storage.reference(forURL: "gs://pushnotificationswiftui.appspot.com/images/\(userUID).jpg")
    imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
        completion(data)
    }
}

struct FirestorageTest_Previews: PreviewProvider {
    static var previews: some View {
        FirestorageTest()
    }
}
