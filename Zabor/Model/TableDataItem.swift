//
//  TableDataItem.swift
//  Zabor
//
//  Created by Alex on 10.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import Foundation

struct TableDataItem {
    let description: String
    let date: String
    let userID: String

    init(description: String, date: String, userID: String) {
        self.description = description
        self.date = date
        self.userID = userID
    }
}
