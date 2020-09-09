//
//  User.swift
//  Zabor
//
//  Created by Alex on 09.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import Foundation
import FirebaseAuth

struct FUser {
    let uid: String
    //let phone: String
    
    init(user: User) {
        self.uid = user.uid
        //self.phone = user.phone
    }
}
