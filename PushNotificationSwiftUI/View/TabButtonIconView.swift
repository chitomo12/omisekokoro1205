//
//  TabButtonIconView.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2022/01/16.
//

import SwiftUI

struct TabButtonIconView: View{
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

struct TabButtonIconView_Previews: PreviewProvider {
    
    static var previews: some View {
        TabButtonIconView(imageName: "envelope", iconName: "Info")
    }
}
