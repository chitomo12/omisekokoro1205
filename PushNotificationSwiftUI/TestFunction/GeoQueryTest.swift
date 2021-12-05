//
//  GeoQueryTest.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/08.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore
import GeoFire

//func loadCommentsTest(){
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
//    var postList: [Post] = []
//
//    // Firestoreのセッティング
//    var db: Firestore!
//    let settings = FirestoreSettings()
//    Firestore.firestore().settings = settings
//    db = Firestore.firestore()
//
//    db.collection("locationCollection")
//        .document("locationDocument")
//        .collection("subLocCollection")
//        .order(by: "latitude")
//        .limit(to: 5)
//        .getDocuments() { (querySnapshot, error) in
////            print("get: \(String(describing: querySnapshot!))")
//            if querySnapshot == nil {
//                print("querySnapshot is nil")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("document: \(String(describing: document.get("name")))")
//                    print("latitude: \(String(describing: document.get("latitude")))")
//                    let postName = String(describing: document.get("name")! )
//                    let postCreatedAt = document.get("created_at") as! Timestamp
//                    let postCreatedAtDate = postCreatedAt.dateValue()
//                    let postCreatedAtString = formatter.string(from: postCreatedAtDate)
//                    let postComment = String(describing: document.get("comment") ?? "" )
//                    postList.append(Post(name: postName, created_at: postCreatedAtString, comment: postComment))
//                }
//                if error != nil {
//                    print("error: \(String(describing: error))")
//                }
//            }
//        }
//}

class Coordinate: ObservableObject{
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
}



struct GeoQueryTest: View {
    @ObservedObject var coordinate = Coordinate()
    
    var body: some View {
        VStack {
            Text("latitude: \(coordinate.latitude)")
            Text("longitude: \(coordinate.longitude)")
            Button( action: {
                storeGeoHash()
            }) {
                Text("Register by GeoQuery")
            }
            .padding()
            Button( action: {
                gatherByGeoHash()
            }) {
                Text("GetData by GeoQuery")
            }
        }
    }
    
    // GeoHashを用いて範囲内に合致するデータを取得する
    func gatherByGeoHash(){
        // Firebase初期設定
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        // Find cities within 50km of London
        let center = CLLocationCoordinate2D(latitude: -65.5074, longitude: -59.1278)
        // Double型の半径（例："50 * 1000"で"50km"）
        let radiusInM: Double = 50 * 1000

        // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
        // a separate query for each pair. There can be up to 9 pairs of bounds
        // depending on overlap, but in most cases there are 4.
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInM)
        let queries = queryBounds.map { bound -> Query in
            return db.collection("cities")
                .document("LON")
                .collection("subCities")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        // マッチしたドキュメント用の変数
        var matchingDocs = [QueryDocumentSnapshot]()
        // Collect all the query results together into a single list
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }

            for document in documents {
                let lat = document.data()["lat"] as? Double ?? 0
                let lng = document.data()["lng"] as? Double ?? 0
                let coordinates = CLLocation(latitude: lat, longitude: lng)
                let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)

                // We have to filter out a few false positives due to GeoHash accuracy, but
                // most will match
                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                if distance <= radiusInM {
                    matchingDocs.append(document)
                }
                print("lat: \(lat), lng: \(lng), center: \(centerPoint)")
                print("get: \(String(describing: document.get("name")))")
            }
        }

        // After all callbacks have executed, matchingDocs contains the result. Note that this
        // sample does not demonstrate how to wait on all callbacks to complete.
        for query in queries {
            print("queries.count: \(queries.count)")
            query.getDocuments(completion: getDocumentsCompletion)
            print("query: \(query)")
        }
    }
    
    // GeoHash付きの座標データを保存
    func storeGeoHash(){
    //    @Binding var coordinate: Coordinate
        
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let latitude = Double.random(in: -90..<90)
        let longitude = Double.random(in: -180..<180)
        let location = CLLocationCoordinate2D(latitude: latitude , longitude: longitude )

        let hash = GFUtils.geoHash(forLocation: location)
        print("hash is initialized")
        print("hash: \(hash)")

        // Add the hash and the lat/lng to the document. We will use the hash
        // for queries and the lat/lng for distance comparisons.
        let documentData: [String: Any] = [
            "geohash": hash,
            "lat": latitude,
            "lng": longitude,
            "createdAt": Date.now
        ]
        print("documentData initialized")

        let londonRef = db.collection("cities")
            .document("LON")
            .collection("subCities")
        londonRef.addDocument(data: documentData) { error in
            // ...
            print("error: \(String(describing:error))")
        }
        print("londonRef is initialized")
        
        coordinate.latitude = latitude
        coordinate.longitude = longitude
        print("latitude: \(latitude)")
        print("longitude: \(longitude)")
    }
}

struct GeoQueryTest_Previews: PreviewProvider {
    static var previews: some View {
        GeoQueryTest()
    }
}
