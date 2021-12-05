//
//  ImageController.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/12/02.
//

import SwiftUI

func getImageFromURL(urlString: String?, completion: @escaping (UIImage) -> () ){
    var url: URL?
    if let temp = urlString {
        print("urlStringは \(temp) です。")
        url = URL(string: temp)
        if url != nil {
            print("urlは \(url) です。")
            var imageData: Data? = nil
            do{
                imageData = try Data(contentsOf: url!)
                if let imageUIImage = UIImage(data: imageData!){
                    completion(imageUIImage)
                }
            } catch {
                print("error loading data from url")
            }
        }
    }
    
}
