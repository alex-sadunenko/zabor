//
//  ViewController.swift
//  Zabor
//
//  Created by Alex on 07.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserViewController: UIViewController {

    let userDefaults = UserDefaults.standard

    // MARK: - IBOutlet
    @IBOutlet weak var customerButton: UIButton! {
        didSet {
            customerButton.setShadow()
        }
    }
    @IBOutlet weak var employeeButton: UIButton! {
        didSet {
            customerButton.setShadow()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            if Auth.auth().currentUser?.uid != nil {
                self.showTargetVC()
            }
        }
    }
    
    private func showTargetVC() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let isCustomer = self.userDefaults.bool(forKey: "isCustomer")
        let isEmployee = self.userDefaults.bool(forKey: "isEmployee")
        
        if isCustomer {
            let tabBarVC = UITabBarController(nibName: "TabBarViewController", bundle: nil)
            UIApplication.shared.windows.first?.rootViewController = tabBarVC
        } else if isEmployee {
            let workVC = mainStoryboard.instantiateViewController(withIdentifier: "WorkViewController") as! WorkViewController
            var navController = UINavigationController()
            navController = UINavigationController(rootViewController: workVC)
            UIApplication.shared.windows.first?.rootViewController = navController
        }
    }
    
    // MARK: - IBAction
    @IBAction func closeSeque(_ sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func customerTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authorizationVC = storyboard.instantiateViewController(withIdentifier: "AuthorizationViewController") as! AuthorizationViewController
        
        userDefaults.set(true, forKey: "isCustomer")
        userDefaults.set(false, forKey: "isEmployee")
        
        self.present(authorizationVC, animated: true)
    }
    
    @IBAction func employeeTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authorizationVC = storyboard.instantiateViewController(withIdentifier: "AuthorizationViewController") as! AuthorizationViewController

        userDefaults.set(false, forKey: "isCustomer")
        userDefaults.set(true, forKey: "isEmployee")

        self.present(authorizationVC, animated: true)
    }
    
}

