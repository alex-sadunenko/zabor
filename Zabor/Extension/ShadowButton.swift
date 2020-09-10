//
//  ShadowButton.swift
//  Zabor
//
//  Created by Alex on 10.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setShadow() {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor(red: 0.05, green: 0.299, blue: 0.571, alpha: 0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
    }
}
