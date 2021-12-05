//
//  ShopData.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/10/31.
//

import Foundation
import UIKit
import SwiftUI

// Identifiableプロトコルを利用した、List表示用の構造体
struct OmiseItem: Identifiable {
    let id = UUID()
    let name: String 
    let coordinates: String
    let address: String
    let omiseImage: UIImage?
    let omiseImageURL: String?
    let omiseUid: String?
//    let omiseSiteURL: String?
}

// Yahoo APIで取得するJSONのデータ構造
struct ResultJson: Codable {
    struct Feature: Codable {
        let Name: String?
        let Geometry: Geometry?
        let Property: Property?
//        let LeadImage: URL?
    }
    // 複数要素（名称は変換元のJSONに合わせる）
    let Feature: [Feature]?
    
    // 入れ子になったデータの解析
    struct Geometry: Codable {
        let Coordinates: String?
    }
    struct Property: Codable {
        let Uid: String?
        let Address: String?
        let LeadImage: URL?
    }
}

struct ResultJsonOfHotpepper: Codable {
    
    struct Results: Codable {
        let shop: [Shop]?
    }
    
    struct Shop: Codable {
        let name: String?
        let lat: Double?
        let lng: Double?
        let address: String?
    }
    
    let results: Results?
    let shop: [Shop]?
}

class OmiseData: ObservableObject{
    // 監視するプロパティに @Published を付与。
    // これによりプロパティを監視し、変化があればサブスクライバー（OmiseSearchView）に通知することができる。
    @Published var omiseList: [OmiseItem] = []
    @Published var isNoOmiseFound: Bool = false
    @Published var isListLoading: Bool = false 
    
    // API検索用メソッド
    func searchOmise(keyword: String) {
        omiseList = []
        // 検索キーワードをエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        // リクエストURLの組み立て
        guard let req_url = URL(string: "https://map.yahooapis.jp/search/local/V1/localSearch?appid=dj00aiZpPW5jakFnV1l4Q0VIcSZzPWNvbnN1bWVyc2VjcmV0Jng9YTU-&output=json&query=\(keyword_encode)") else {
            return
        }
        // リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: { (data, response, error) in
            //セッションを終了
            session.finishTasksAndInvalidate()
            // do try catch エラーハンドリング
            do {
                let decoder = JSONDecoder()  // JSONデコーダーのインスタンス取得
                if let tempData = data {
                    let json = try decoder.decode(ResultJson.self, from: tempData)  // 解析
                    // ResultJson構造のデータ群をOmiseItem構造のデータ群に置換
                    if let items = json.Feature {
                        self.omiseList.removeAll()  // リストを初期化
                        
                        // 取得した数だけ処理
                        for item in items {
                            // 画像があれば格納、無ければダミー画像
                            let omiseImageURL: URL? = item.Property?.LeadImage
                            let omiseImageUIImage: UIImage?
                            if omiseImageURL != nil{
                                let omiseImageData: Data? = try? Data(contentsOf: omiseImageURL!)
                                if omiseImageData != nil{
                                    omiseImageUIImage = UIImage(data: omiseImageData!)
                                } else {
                                    omiseImageUIImage = UIImage(named: "SampleImage")
                                }
                            } else {
                                omiseImageUIImage = UIImage(named: "SampleImage")
                            }
                            
                            // サイトURLが
                            if let name = item.Name,
                               let geometry = item.Geometry,
                               let coordinates = geometry.Coordinates,
                               let property = item.Property,
                               let address = property.Address {
                                let omise = OmiseItem(name: name,
                                                      coordinates: coordinates,
                                                      address: address,
                                                      omiseImage: omiseImageUIImage,
                                                      omiseImageURL: omiseImageURL?.absoluteString,
                                                      omiseUid: item.Property?.Uid
                                )
                                self.omiseList.append(omise)
                            }
                        }
                        print("self.omiseList.count: \(self.omiseList.count)")
                    } else {
                        // 解析したデータ（json.Feature）がnilだった場合の処理
                        print("お店が見つかりません")
                        self.isNoOmiseFound = true
                        self.isListLoading = false 
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        })
        task.resume()  // ダウンロード開始
    } // searchOmiseここまで
    
    // Hotpepper API版
    func searchOmiseByHotpepper(keyword: String) {
        print("searchOmiseByHotpepparの処理を開始")
        omiseList = []
        // 検索キーワードをエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        print("リクエストURLを組み立てます")
        guard let req_url = URL(string: "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=8363c56cc81dbf83&format=json&name=\(keyword_encode)") else {
            return
        }
        print("リクエストURL：\(req_url)")
        print("リクエストに必要な情報を生成します")
        // リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        print("リクエストをタスクとして登録します")
        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: { (data, response, error) in
            print("セッションを終了しました")
            //セッションを終了
            session.finishTasksAndInvalidate()
            print("エラーハンドリングを行います")
            // do try catch エラーハンドリング
            do {
                print("data!: \(String(describing: data!))")
                print("JSONデコーダーのインスタンスを取得")
                let decoder = JSONDecoder()  // JSONデコーダーのインスタンス取得
                let json = try decoder.decode(ResultJsonOfHotpepper.self, from: data!)  // 解析
                print("解析完了：\(json)")
                // ResultJson構造のデータ群をOmiseItem構造のデータ群に置換
                if let items = json.results?.shop {
                    print("omiseListに追加します")
                    self.omiseList.removeAll()  // リストを初期化
                    // 取得した数だけ処理
                    for item in items {
                        if let name = item.name,
                           let latitude = item.lat,
                           let longitude = item.lng,
                           let address = item.address {
                            print("name: \(name), latitude: \(latitude), longitude: \(longitude), address: \(address)")
                        } else {
                            print("追加しませんでした：\(item)")
                        }
                    }
                    print("self.omiseList.count: \(self.omiseList.count)")
                }
            } catch {
                print("Error: \(error)")
            }
        })
        task.resume()  // ダウンロード開始
        
    }
}
