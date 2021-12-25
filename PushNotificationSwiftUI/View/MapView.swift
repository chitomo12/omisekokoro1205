//
//  MapView.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/10/30.
//

import SwiftUI
import MapKit
import CoreLocation
import GeoFire

struct MapView: UIViewRepresentable {
    @EnvironmentObject var environmentCurrentUser: UserData
    @EnvironmentObject var isShowProgress: ShowProgress
    @EnvironmentObject var isShowPostDetailPopover: IsShowPostDetailPopover
    
//    @ObservedObject var postData = PostData()
    
    @Binding var mapSwitch: MapSwitch
    
    @Binding var map: MKMapView
    
    // 投稿詳細ポップオーバー表示用のブーリアン（trueでポップオーバーが表示される）
    @Binding var isShowingDetailPopover: Bool
    // 投稿詳細コンテンツ表示用のブーリアン
    @Binding var isShowingDetailContent: Bool
    
    // アノテーションを選択時にポップオーバーに渡す値
    @Binding var selectedPostDocumentID: String?
    @Binding var selectedPostAnnotation: MKAnnotationView
    @Binding var selectedPost: Post
    @Binding var selectedPostImageData: Data?
    @Binding var selectedPostImageUIImage: UIImage?
    @Binding var selectedPostUserImageUIImage: UIImage
    
    @Binding var isFavoriteAddedToSelectedPost: Bool
    @Binding var FavoriteID: String
    @Binding var isBookmarkAddedToSelectedPost: Bool
    @Binding var BookmarkID: String
    
    // ローディング表示判定用Boolean（初期値：true。初回読み込み後にfalse）
    @Binding var isLoadingAnnotationViews: Bool
    
    // 初回起動時の座標
    @State var targetCoordinate = CLLocationCoordinate2D(latitude: 35.3931, longitude: 139.4444)
        
//    var viewController = ViewController()
    
    // 表示するViewを作成する時に実行
    func makeUIView(context:Context) -> MKMapView {
        map.delegate = context.coordinator  // デリゲートを設定
        map.addGestureRecognizer(context.coordinator.myLongPress)
        return map
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //表示したViewが更新されるたびに実行
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("mapSwitch: \(mapSwitch) の処理を行います")
        switch mapSwitch{
        // 初回起動時の挙動
        case .initialized:
            uiView.region = MKCoordinateRegion(
                center: targetCoordinate,
                latitudinalMeters: 100000.0,
                longitudinalMeters: 100000.0
            )
            mapSwitch = .normal
        default:
            print("mapSwitchはデフォルトです")
        } // switchその２ ここまで
    } // func updateUIView ここまで
    
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var tappedLatitude: Double = 0
        var tappedLongitude: Double = 0
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        var locationManager: CLLocationManager!
        var annotationTitle: String = ""
        var annotationSubtitle: String = ""
        
        //表示領域変更時用の変数
        var lastLoadingPoint = CLLocation(latitude: 0.0, longitude: 0.0)  // targetCoordinateで初期化
        var lastStoppingPoint = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        var lastAddingAnnotations: [MKAnnotation] = []
        var generateImageViewController = GenerateImageViewController()
        
        init(_ parent: MapView){
            self.parent = parent
            super.init()
            self.myLongPress.addTarget(self, action: #selector(recognizeLongPress))
        }
        
        // ロングタップ時の挙動（廃止or変更予定）
        @objc func recognizeLongPress(sender: UILongPressGestureRecognizer) {
            print("ロングタップ時の処理を開始します")
            // ロケーションマネジャーのセットアップ
            locationManager = CLLocationManager()
            
            if sender.state == .began {
                print("In")
            } else if sender.state == .ended {
                print("Out")
                if let mapView = sender.view as? MKMapView {
                    // タップ位置を取得
                    let point = sender.location(in: mapView)
                    // MapViewでの座標に変換
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                    // タップ位置に照準を合わせる
                    let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta,
                                                longitudeDelta: mapView.region.span.longitudeDelta)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    // アニメーションをつけて表示座標を移動
                    mapView.setRegion(region, animated: true)
                }
            }
        } // ロングタップ時の挙動ここまで
        
        // addAnnotationの際に呼ばれる、アノテーションを返すメソッド
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "pin"
            // アノテーションビューを作成する
            var annotationView: MKMarkerAnnotationView!
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            annotationView.titleVisibility = .hidden
            annotationView.subtitleVisibility = .hidden
            // なぜかTintとGlyphが重なって表示されるため、透明にすることで応急処置
            annotationView.markerTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
            annotationView.glyphTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
            annotationView.animatesWhenAdded = true
            annotationView.centerOffset = CGPoint(x: 0, y: -50)
//            annotationView.clusteringIdentifier = annotation.title as! String
            
            // String型のデータ（annotation.comment）を与えることで動的に生成されたUIImageを返す（仮実装）
            annotationView.image = self.generateImageViewController.setup(commentText: (annotation.subtitle ?? "") ?? "")
            
            return annotationView
        } // アノテーションを返すメソッドここまで
        
        // アノテーションがタップ（選択）されたら呼ばれるメソッド
        func mapView(_ mapView: MKMapView, didSelect annotationView: MKAnnotationView) {
            print("アノテーションがタップされました: \(annotationView.annotation!.title!!)")
            // ポップオーバーを表示（コンテンツはローディング表示）
            self.parent.isShowingDetailPopover = true
            
            // コンテンツはローディング表示
            self.parent.isShowingDetailContent = false
            
            // アノテーションが保持するdocumentIDからポストの詳細を取得し、詳細画面を表示する
            let documentKeyId = annotationView.annotation!.title!!
            let postData = PostData()
            postData.getPostDetail(documentKeyID: documentKeyId, completion: { onePost in
                // 削除するパターン分岐に備え、アノテーションを渡しておく
                self.parent.selectedPostAnnotation = annotationView
                // ドキュメントID自体はドキュメント内に保持されないので別に変数を用意して格納する
                self.parent.selectedPostDocumentID = onePost.documentId
                // 投稿者名、コメント文などが格納されたドキュメント情報を渡す
                self.parent.selectedPost = onePost
                // 投稿者名を環境変数に渡す（削除ボタンの表示判定に使用）
                self.parent.isShowPostDetailPopover.selectedPostCreateUserUID = onePost.created_by!
                
                // お店画像の読み込み（登録がない場合はダミー画像を表示）
                let postImageURL: URL? = URL(string: onePost.imageURL ?? "")
                if postImageURL != nil{
                    print("①postImageURL: \(String(describing:postImageURL))を読み込みます")
                    do{
                        self.parent.selectedPostImageData = try Data(contentsOf: postImageURL!)
                    } catch {
                        print("error")
                    }
                } else {
                    print("②postImageURLがnilです")
                    self.parent.selectedPostImageData = nil
                    self.parent.selectedPostImageUIImage = nil
                }
                
                if self.parent.selectedPostImageData != nil{
                    print("③")
                    self.parent.selectedPostImageUIImage = UIImage(data: self.parent.selectedPostImageData!)!
                } else {
                    print("④Error")
                    self.parent.selectedPostImageUIImage = nil
                }
                
                // ファボ、ブックマークの判定
                print("check start")
                CheckFavorite(postID: onePost.documentId, currentUserID: self.parent.environmentCurrentUser.uid, completion: { resultBool, foundedFavID in
                    self.parent.isFavoriteAddedToSelectedPost = resultBool
                    self.parent.FavoriteID = foundedFavID
                    
                    CheckBookmark(postID: onePost.documentId, currentUserID: self.parent.environmentCurrentUser.uid, completion: { resultBool, foundedBookmarkID in
                        self.parent.isBookmarkAddedToSelectedPost = resultBool
                        self.parent.BookmarkID = foundedBookmarkID
                        
                        getUserImageFromFirestorage(userUID: onePost.created_by ?? "GuestUID") { data in
                            if data != nil {
                                print("投稿者プロフィール画像を読み込みます：\(data!)")
                                self.parent.selectedPostUserImageUIImage = UIImage(data: data!)!
                                print("読み込みました")
                            } else {
                                print("\(String(describing: onePost.created_by))のプロフィール画像が見つかりません")
                                self.parent.selectedPostUserImageUIImage = UIImage(named: "SampleImage")!
                            }
                            
                            // 投稿詳細内容を表示
                            self.parent.isShowingDetailContent = true
                        }
                    })
                })
                
            })
            // 同じアノテーションを連続タップすると反応がなくなる不具合：
            // 　- タップするとアノテーションが選択状態になるため、選択状態を解除してあげる。
            for annotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(annotation, animated: false)
            }
        }
        // アノテーションが選択されたら呼ばれるメソッドここまで
        
        // 起動直後、および表示領域変更時に呼ばれる
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            self.parent.isLoadingAnnotationViews = true
            // 新しい表示領域内のコメントを取得（仮実装）
            print("【func mapView】 表示領域が変更されました")
            let mapRegion = mapView.region
            let mapCenter = mapRegion.center
            
            // 地球の円周：40000km　→ 赤道における経度１度当たりの距離：40000km / 360°
            let kilometerPerLongitude: Double = 40000 / 360
            print("現在のマップ表示幅：\(mapRegion.span.longitudeDelta * kilometerPerLongitude) km")
            
            // 現在の表示幅(LongitudeDelta：LD)を基準に、表示幅の半分(LD/2)だけ移動したらコメントを再読み込みする。
            // 最後に取得を行なった地点(lastLoadingPoint)を地点Aとし、地点Aと移動後の画面中心(lastStoppingPoint)の地点Bとの距離Distanceを測り、
            // Distanceが表示幅の半分(LD/2)を超えていた場合に再取得を実行する。
            // 実行後、再取得を行なった地点を地点Aとして設定し、最初に戻る。
            let lastStoppingPoint = CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
            let dist = lastLoadingPoint.distance(from: lastStoppingPoint)
            let threshold = 1000 * mapRegion.span.longitudeDelta * kilometerPerLongitude / 2  // 閾値
            if dist > threshold {
                mapView.removeAnnotations(mapView.annotations)
                // 移動距離が閾値を超えた場合の処理
                print("dist is over。コメントを読み込みます。")
                lastLoadingPoint = lastStoppingPoint
                
                //現在地点を中心に、周囲50km圏内のコメントを取得する（仮実装）
                print("中心: \(mapCenter)、半径: \(mapRegion.span.longitudeDelta * kilometerPerLongitude / 2) km領域内のコメントを読み込みます。")
                let postData = PostData()
                postData.getPostListAround(givenCenter: mapCenter,
//                parent.postData.getPostListAround(givenCenter: mapCenter,
                                                  radius: 1000 * mapRegion.span.longitudeDelta * kilometerPerLongitude / 2,
                                                  completion: { completionPost in
                        // 非同期的に、読み込み終了後にピンを追加するクロージャ
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = completionPost.coordinate
                        annotation.title = completionPost.documentId
                        // コメントはannotationのsubtitleプロパティに渡す
                        annotation.subtitle = completionPost.comment
                        print("アノテーション「\(String(describing: annotation.subtitle))」を追加しました")
                        mapView.addAnnotation(annotation)
                    }
                )
                self.parent.isLoadingAnnotationViews = false
            } else {
                // 距離が閾値に満たない場合の処理
                print("dist isn't over。コメントは読み込みません")
                self.parent.isLoadingAnnotationViews = false
            }
        } // 領域変更時のfunc mapViewここまで
    } // class Coordinatorここまで
}
