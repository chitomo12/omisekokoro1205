//
//  ViewControllerStudy.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/14.
//

import SwiftUI

struct ViewControllerForGenerateImage: View {
    var body: some View {
        SampleViewControllerWrapper()
    }
}

struct SampleViewControllerWrapper: UIViewControllerRepresentable {
    // UIViewControllerオブジェクトを生成し、初期化
    func makeUIViewController(context: Context) -> GenerateImageViewController {
        return GenerateImageViewController()
    }
    // SwiftUIからの情報をもとにViewControllerを更新する
    func updateUIViewController(_ uiViewController: GenerateImageViewController, context: Context) {
        
    }
}

class GenerateImageViewController: UIViewController {
    
    // ライフサイクル①
    override func loadView(){
        super.loadView()  // 上位ビューのloadViewを実行しないとクラッシュする？
    }
    
    // Lifecycle 6
    override func viewDidAppear(_ animated: Bool) {
//        setup(commentText: "サンプルサンプルサンプルサンプルサンプルサンプルサンプル")
    }
    
    func setup(commentText: String) -> UIImage {
        
        let text = commentText
        // 吹き出しのフォントサイズ
        let font = UIFont.boldSystemFont(ofSize: 16)
        // 描画領域を生成
        let drawingRectWidth = 100.0 * 3
        let drawingRectHeight = 100.0
                
        // テキストの描画領域
        let textRect = CGRect(x: 15, y: 15, width: 250, height: 100)
        let textStyle = NSMutableParagraphStyle()
        textStyle.lineBreakMode = .byCharWrapping
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor(red: 0.2, green: 0.1, blue: 0.1, alpha: 0.9),
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        
        // テキストサイズを動的に取得するためのUILabelを宣言
        let labelRect = CGRect(x: 0, y: 0, width: 250, height: 100)
        let label = UILabel()
        label.frame = labelRect
        label.text = "\(text)"
        label.font = font
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        // テキストの最大横幅を指定
        let maxlabelRectSize = CGSize(width: 250, height: 100)
        let labelRectSize: CGSize = label.sizeThatFits(maxlabelRectSize) // labelの動的サイズを取得
        label.frame = CGRect(x: 0, y: 0, width: labelRectSize.width, height: labelRectSize.height)  // labelのフレームサイズを更新
        
        // ランダムに色を取り出す
        let colorStringArray = ["ColorOne", "ColorTwo", "ColorThree", "ColorFour"]
        let randomSelectedColorString = colorStringArray.randomElement()
        
        
        // ~~~~~~~~~~~~~~~~~~~~~
        // Context開始
        UIGraphicsBeginImageContextWithOptions(CGSize(width: labelRectSize.width + 40, height: labelRectSize.height + 40), false, 0.0)
        
        // カラー影の四角形
        let shadowRectangle = UIBezierPath(roundedRect: CGRect(x: 4, y: 4, width: labelRectSize.width+30, height: labelRectSize.height+30), cornerRadius: 3)
        UIColor(named: randomSelectedColorString!)!.setFill()
        shadowRectangle.fill()
        
        // 吹き出し下のカラー三角形を描写
        let randomCGFloat = CGFloat(Int.random(in: -5...5))
        let path = UIBezierPath()
        let triangleStartX = (labelRectSize.width + 30) / 2
        let triangleStartY = labelRectSize.height + 31
        path.move(to: CGPoint(x: triangleStartX, y: triangleStartY ))
        path.addLine(to: CGPoint(x: triangleStartX + randomCGFloat + 10, y: triangleStartY))
        path.addLine(to: CGPoint(x: triangleStartX, y: triangleStartY + 10))
        path.addLine(to: CGPoint(x: triangleStartX + randomCGFloat - 10, y: triangleStartY))
        path.close()
        path.fill()
        
        // 白い四角形を描写
        let rectangle = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: labelRectSize.width+30, height: labelRectSize.height+30), cornerRadius: 3)
        UIColor(red: 255/255, green: 250/255, blue: 250/255, alpha: 0.97).setFill()
        rectangle.fill()
        
        // テキストをレンダリング
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        // Contextに描画された画像を設定
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // Context終了
        UIGraphicsEndImageContext()
        // ~~~~~~~~~~~~~~~~~~~~
        
        // UIImageViewインスタンス生成
        let newImageView = UIImageView()
        newImageView.image = newImage
        newImageView.frame = CGRect(x: 0, y: 0, width: drawingRectWidth, height: drawingRectHeight)
        
        self.view.addSubview(newImageView)
        
        return newImage!
    }
    
    // Lifecycle 7
    override func viewWillDisappear(_ animated: Bool) {
    }
    // Lifecycle 8
    override func viewDidDisappear(_ animated: Bool) {
    }
}

struct ViewControllerStudy_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerForGenerateImage()
            .previewLayout(.fixed(width:300, height: 300))
    }
}
