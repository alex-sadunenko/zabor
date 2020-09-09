//
//  ViewController.swift
//  Zabor
//
//  Created by Alex on 07.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var customerButton: UIButton!
    @IBOutlet weak var employeeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            if Auth.auth().currentUser?.uid != nil {
                // здесь можно прописать переход на контроллер работы, но для этого надо знать, это заказчик или подрядчик
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let workVC = storyboard.instantiateViewController(withIdentifier: "WorkViewController") as! WorkViewController
                //workVC.isCustomer = true
                let navController = UINavigationController(rootViewController: workVC)
                navController.modalPresentationStyle = .overFullScreen
                self.present(navController, animated: true)
            }
        }
    }

    // MARK: - IBAction
    @IBAction func closeSeque(_ sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func customerTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authorizationVC = storyboard.instantiateViewController(withIdentifier: "AuthorizationViewController") as! AuthorizationViewController
        authorizationVC.isCustomer = true
        self.present(authorizationVC, animated: true)
    }
    
    @IBAction func employeeTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authorizationVC = storyboard.instantiateViewController(withIdentifier: "AuthorizationViewController") as! AuthorizationViewController
        authorizationVC.isCustomer = false
        self.present(authorizationVC, animated: true)
    }
}

