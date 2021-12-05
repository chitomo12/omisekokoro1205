//
//  EnvFirebase.swift
//  MyMap1030
//
//  Created by 福田正知 on 2021/11/28.
//

import SwiftUI
import Firebase

class EnvFirebase: ObservableObject{
    @Published var db: Firestore!
    
    init(){
        Firestore.firestore().settings = FirestoreSettings()
        db = Firestore.firestore()
    }
}
