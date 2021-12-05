//
//  GenerateUIImageTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/14.
//

import SwiftUI

struct GenerateUIImageTest: View {
    var generateImageViewController = GenerateImageViewController()
    @State var commentText = "サンプルサンプルサンプルサンプルサンプルサンプル"
    
    var body: some View {
        VStack {
            TextField("title", text: $commentText, prompt: Text("Type"))
            Image(uiImage: generateImageViewController.setup(commentText: commentText))
        }
    }
}

struct GenerateUIImageTest_Previews: PreviewProvider {
    static var previews: some View {
        GenerateUIImageTest()
    }
}
