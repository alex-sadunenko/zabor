//
//  CustomerViewController.swift
//  Zabor
//
//  Created by Alex on 10.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CustomerViewController: UIViewController {

    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
    }
    
    // MARK: - Configure Navigation
    func configureNavigation() {
        navigationItem.title = "Заказчик"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.xmark"), style: .plain, target: self, action: #selector(dismissToMainMenu))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }

    @objc func dismissToMainMenu() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "closeSeque", sender: self)
        } catch {
            
        }
        print("dismissToMainMenu")
        do {
            try Auth.auth().signOut()
            userDefaults.set(false, forKey: "isCustomer")
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let userViewController = mainStoryBoard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            UIApplication.shared.windows.first?.rootViewController = userViewController
        } catch {
            
        }
    }

}
