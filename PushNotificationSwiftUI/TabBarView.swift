//
//  TabBarView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/06.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTag: Int
    
    var body: some View {
        HStack(alignment: .top) {
            TabButtonView(selectedTag: $selectedTag, tagNumber: 1, nameOfImage: "globe.asia.australia", buttonText: "マップ")
            .background(Color(red: 242/255, green: 82/255, blue: 170/255, opacity: 1.0))
            
            TabButtonView(selectedTag: $selectedTag, tagNumber: 2, nameOfImage: "magnifyingglass", buttonText: "検索")
            .background(Color(red: 5/255, green: 199/255, blue: 242/255, opacity: 1.0))
            
            TabButtonView(selectedTag: $selectedTag, tagNumber: 3, nameOfImage: "person", buttonText: "マイページ")
            .background(Color(red: 242/255, green: 226/255, blue: 5/255, opacity: 1.0))
        }
        .frame(maxHeight: 100)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(selectedTag: .constant(1))
    }
}
