//
//  LocationManager.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/10/30.
//

import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var region = MKCoordinateRegion()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization() // プライバシー設定の確認
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 // 更新距離（ｍ）
        manager.startUpdatingLocation()  //追従を開始する
    }
    
    //領域の更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            let center = CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude)
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 500.0,
                longitudinalMeters: 500.0
            )
        }
    }
    
    
}

//struct LocationManager: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct LocationManager_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationManager()
//    }
//}
