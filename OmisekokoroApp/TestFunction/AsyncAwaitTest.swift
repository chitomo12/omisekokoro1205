//
//  AsyncAwaitTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/11.
//

import SwiftUI

actor ViewModel: ObservableObject {
    @MainActor @Published var message: String?
    var count: Int = 0
    func fetchMessage(url: String) async -> String? {
        await Task.sleep(1 * 1000 * 1000 * 1000)
        count += 1
        let result = url + "?count=\(count)"
        // @MainActorのキーワードプロパティをメインスレッドから変更するための記述
        await MainActor.run { [weak self] in
            self?.message = result
        }
        return result
    }
}

struct AsyncAwaitTest: View {
    @StateObject var model = ViewModel()
    
    var body: some View {
        VStack{
            Text(model.message ?? "")
                .padding()
            Button("push me"){
                didTapButton()
            }
        }
    }
    
    func didTapButton(){
        // 同期処理から非同期処理を呼び出すときはTaskを使う
        Task {
            // asyncのメソッドを呼ぶときはawaitをつける
            let result1 = await model.fetchMessage(url: "https://apple.com")
            //
            print("result1: \(String(describing: result1))")
            let result2 = await model.fetchMessage(url: "https://aoole.com")
            print("result2: \(String(describing: result2))")
        }
    }
}

struct AsyncAwaitTest_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitTest()
    }
}
