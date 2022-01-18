//
//  splashSample.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/18.
//

import SwiftUI

struct AnimationTest: View {
    @State var rotation = false
    @State var drag: CGSize = .zero
    
    var body: some View {
        VStack{
            Image(systemName:"cloud.sun")
                .font(.largeTitle)
                .rotationEffect(Angle.degrees(rotation ? 0 : 360))
                .animation(Animation.spring(response:0.5, dampingFraction: 0.8, blendDuration: 0.1), value: rotation)
            
            HStack {
                VStack{
                    Image(systemName: "cloud.sun.bolt")
                    .font(.largeTitle)
                    .rotationEffect(Angle.degrees(rotation ? 0 : 360))
                    .animation(Animation.easeInOut, value: rotation)
                    .offset(drag)
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                self.drag = value.translation
                                
                            }
                            .onEnded{ _ in
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.5)) {
                                    self.drag = .zero
                                }
                            }
                    )
                    .onTapGesture(perform: {
                        self.rotation.toggle()
                    })
                    
                }
            }
            Button(action: {
                self.rotation.toggle()
            }) {
                Text("anime")
            }
        }
    }
}

struct splashSample_Previews: PreviewProvider {
    static var previews: some View {
        AnimationTest()
    }
}
