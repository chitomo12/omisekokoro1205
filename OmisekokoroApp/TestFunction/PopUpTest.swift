//
//  PopUpTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/02.
//

import SwiftUI


struct PopUpTest: View {
  @State var isPresented = false

  var body: some View {
    VStack {
      Button(action: {
        self.isPresented = true
      }) {
        Text("Show")
      }
    }
    .popup(isPresented: $isPresented) {
        MyPopup(isPresented: $isPresented)
    }
  }
}

struct MyPopup: View {
    @Binding var isPresented: Bool
    
  var body: some View {
      VStack {
          Text("Hello!")
          Button(action: {
              isPresented.toggle()
          }) {
              Text("Close!")
          }
      }
      .foregroundColor(.white)
      .padding(16)
      .background(Color.pink)
      .cornerRadius(8)
  }
}

extension View {
  func popup<Content: View>(isPresented: Binding<Bool>, content: () -> Content) -> some View {

    if isPresented.wrappedValue {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        isPresented.wrappedValue = false
//      }
    }

    return ZStack {
      self

      content()
        .opacity(isPresented.wrappedValue ? 1 : 0)
        .scaleEffect(isPresented.wrappedValue ? 1 : 0)
//        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0))
    }
  }
}
//
//struct PopupView: View{
//    @Binding var isPresent: Bool
//    var body: some View {
//        VStack{
//            Text("Snowlax")
//            Text("Snorlax (Japanese: カビゴン Kabigon) is a Normal-type Pokemon. Snorlax is most popular Pokemon.")
//            Button(action: {
//                withAnimation{
//                    isPresent = false
//                }
//            }){
//                Text("Close")
//            }
//        }
//        .frame(alignment: .center)
//        .padding(10)
//        .background(.white)
//        .cornerRadius(12)
//        .shadow(radius:5)
//        .scaleEffect($isPresent.wrappedValue ? 1 : 0)
//        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 1))
//    }
//}

struct PopUpTest_Previews: PreviewProvider {
    static var previews: some View {
        PopUpTest()
    }
}
