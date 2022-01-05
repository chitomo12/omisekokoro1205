//
//  PHPickerViewController.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/29.
//

import SwiftUI
import PhotosUI
import Photos
 
// 写真選択画面のビュー
struct PHPickerView: UIViewControllerRepresentable {
    // sheetが表示されているか
    @Binding var isShowPHPicker: Bool
    // フォトライブラリーから読み込む写真
    @Binding var selectedImage: UIImage?
    
    // Coordinatorでコントローラのdelegateを管理
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        // PHPickerView型の変数を用意
        var parent: PHPickerView
        // イニシャライザ（必須）
        init(parent: PHPickerView) {
            self.parent = parent
        }
        // ライブラリーで写真を選択・キャンセルした際に実行されるdelegateメソッド（必須）
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // 写真は最初の１件のみ指定
            if let result = results.first {
                // UIImage型の写真のみ非同期で取得
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    // 写真が取得できた場合
                    if let unwrapImage = image as? UIImage {
                        //選択された写真をselectedImageに格納する
                        self.parent.selectedImage = unwrapImage
                    } else {
                        print("使用できる写真がありません")
                    }
                }
            } else {
                print("選択された写真がありません")
            }
            parent.isShowPHPicker = false
        } //pickerここまで
    } //Coordinatorここまで
    
    // Coordinatorを生成
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // Viewを生成する時に実行
    func makeUIViewController(context: UIViewControllerRepresentableContext<PHPickerView>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        // delegate設定
        picker.delegate = context.coordinator
        return picker
    }
    
    // View更新時に実行
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PHPickerView>) {
        // 処理なし
    }
    
} //PHPickerViewここまで
