//
//  Product.swift
//  Zabor
//
//  Created by Alex on 09.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Product {
    let userID: String
    let description: String
    let date: String
    let latitude: Double
    let longitude: Double
    var isCheck: Bool
    let ref: DatabaseReference?
    
    init(userID: String, description: String, date: String, latitude: Double, longitude: Double, isCheck: Bool, ref: DatabaseReference?) {
        self.userID = userID
        self.description = description
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.isCheck = false
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        userID = snapshotValue["userID"] as! String
        description = snapshotValue["description"] as! String
        date = snapshotValue["date"] as! String
        latitude = snapshotValue["latitude"] as! Double
        longitude = snapshotValue["longitude"] as! Double
        isCheck = snapshotValue["isCheck"] as! Bool
        ref = snapshot.ref
    }
}
