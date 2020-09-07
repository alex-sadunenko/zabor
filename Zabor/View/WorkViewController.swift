//
//  WorkViewController.swift
//  Zabor
//
//  Created by Alex on 07.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit

class WorkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        
    }
    
    func configureNavigation() {
        //navigationController?.navigationBar.barTintColor = .darkGray
        //navigationController?.navigationBar.barStyle = .default
        navigationItem.title = "Подрядчик"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.xmark"), style: .plain, target: self, action: #selector(dismissToMainMenu))

    }
    
    @objc func dismissToMainMenu() {
        performSegue(withIdentifier: "closeSeque", sender: self)
        print("dismissToMainMenu")
    }
    
}
