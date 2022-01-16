//
//  RedButtonView.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/07.
//

import SwiftUI

struct RedButtonView: View {
    @State var buttonText: String
    
    var body: some View {
        let linearGradientForButton = LinearGradient(colors: [Color("ColorTwo"), Color("ColorThree")], startPoint: .bottomLeading, endPoint: .topTrailing)
        
        Text(buttonText)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 200, height: 40, alignment: .center)
            .background(linearGradientForButton)
            .cornerRadius(20)
    }
}

struct RedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RedButtonView(buttonText: "ボタン")
    }
}
