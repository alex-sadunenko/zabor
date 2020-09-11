//
//  AuthorizationViewController.swift
//  Zabor
//
//  Created by Alex on 07.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthorizationViewController: UIViewController {

    var verificationID: String!
    
    // MARK: - IBOutlet
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var fetchCodeButton: UIButton! {
        didSet {
            fetchCodeButton.setShadow()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBAction
    @IBAction func fetchCodeTapped(_ sender: UIButton) {
        guard let phoneNumber = phoneNumber else { return }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.text!, uiDelegate: nil) { (data, error) in
            if error != nil {
                print(error?.localizedDescription ?? "is empty")
            } else {
                self.showCodeValidationVC(verificationID: data!)
            }
        }
    }
    
    // MARK: - Code Validation
    private func showCodeValidationVC(verificationID: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let codeValidationVC = storyboard.instantiateViewController(withIdentifier: "CodeValidationViewController") as! CodeValidationViewController
        codeValidationVC.verificationID = verificationID
        self.present(codeValidationVC, animated: true)
    }

}
