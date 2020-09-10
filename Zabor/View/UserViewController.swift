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
    @IBOutlet weak var customerButton: UIButton!
    @IBOutlet weak var employeeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            if Auth.auth().currentUser?.uid != nil {
                self.showTargetVC()
                
//                //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                //
//                //                var navController = UINavigationController()
//                //                let isCustomer = self.userDefaults.bool(forKey: "isCustomer")
//                //                if isCustomer {
//                //                    let customerVC = storyboard.instantiateViewController(withIdentifier: "CustomerViewController") as! CustomerViewController
//                //                    navController = UINavigationController(rootViewController: customerVC)
//                //                } else {
//                //                    let workVC = storyboard.instantiateViewController(withIdentifier: "WorkViewController") as! WorkViewController
//                //                    navController = UINavigationController(rootViewController: workVC)
//                //                }
//                //
//                //                navController.modalPresentationStyle = .overFullScreen
//                //                self.present(navController, animated: true)
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//                var navController = UINavigationController()
//                let isCustomer = self.userDefaults.bool(forKey: "isCustomer")
//                if isCustomer {
//                    let customerVC = storyboard.instantiateViewController(withIdentifier: "CustomerViewController") as! CustomerViewController
//                    let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
//                    let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
//
//                    let navCustomerController = UINavigationController(rootViewController: customerVC)
//                    let navReportController = UINavigationController(rootViewController: reportVC)
//                    let navMapController = UINavigationController(rootViewController: mapVC)
//
//                    let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//                    tabBarVC.setViewControllers([navCustomerController,navReportController,navMapController], animated: true)
//                    tabBarVC.modalPresentationStyle = .overFullScreen
//
//                    //                    let story = UIStoryboard(name: "Main", bundle:nil)
//                    //                    UIApplication.shared.windows.first?.rootViewController = vc
//                    //                    UIApplication.shared.windows.first?.makeKeyAndVisible()
//                    //
//                    self.present(tabBarVC, animated: true)
//
//                } else {
//                    let workVC = storyboard.instantiateViewController(withIdentifier: "WorkViewController") as! WorkViewController
//                    navController = UINavigationController(rootViewController: workVC)
//                    navController.modalPresentationStyle = .overFullScreen
//                    self.present(navController, animated: true)
//                }
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
    }}

