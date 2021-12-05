//
//  TabButtonView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/12.
//

import SwiftUI

struct TabButtonView: View{
    @Binding var selectedTag: Int
    
    let tagNumber: Int 
    let nameOfImage: String
    let buttonText: String
    
    var body: some View {
        Button(action: {selectedTag = tagNumber}, label: {
            VStack{
                Image(systemName: nameOfImage)
                Text("\(buttonText)").fontWeight(.heavy)
                    .padding(.top, 5.0)
            }
            .padding(.top, 0.0)
            .frame(maxWidth:.infinity, maxHeight: .infinity)
        })
        .foregroundColor(.white)
        .cornerRadius(30)
    }
}

struct TabButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TabButtonView(selectedTag: .constant(1), tagNumber: 1, nameOfImage: "person", buttonText: "マイページ")
        
    }
}
