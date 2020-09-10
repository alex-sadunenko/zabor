//
//  CodeValidationViewController.swift
//  Zabor
//
//  Created by Alex on 07.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth

class CodeValidationViewController: UIViewController {

    var verificationID: String!
    let userDefaults = UserDefaults.standard

    // MARK: - IBOutlet
    @IBOutlet weak var codeTextView: UITextView!
    @IBOutlet weak var checkCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConfig()
        codeTextView.becomeFirstResponder()
    }
    
    // MARK: - IBAction
    @IBAction func checkCodeTapped(_ sender: UIButton) {
        guard let code = codeTextView.text else { return }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        Auth.auth().signIn(with: credential) { (_, error) in
            if error != nil {
                let alertController = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancel)
                self.present(alertController, animated: true)
            } else {
                self.showTargetVC()
            }
        }
    }
    
    private func showTargetVC() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
 
        let isCustomer = self.userDefaults.bool(forKey: "isCustomer")
        let isEmployee = self.userDefaults.bool(forKey: "isEmployee")
        if isCustomer {
            let tabBarVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            UIApplication.shared.windows.first?.rootViewController = tabBarVC
        } else if isEmployee {
            let workVC = mainStoryboard.instantiateViewController(withIdentifier: "WorkViewController") as! WorkViewController
            var navController = UINavigationController()
            navController = UINavigationController(rootViewController: workVC)
            UIApplication.shared.windows.first?.rootViewController = navController
        }
        
    }

    private func setupConfig() {
        checkCodeButton.alpha = 0.5
        checkCodeButton.isEnabled = false
        
        codeTextView.delegate = self
    }

}

//MARK: - TextView Delegate
extension CodeValidationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = textView.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLengs = currentCharacterCount + text.count - range.length
        return newLengs <= 6
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 6 {
            checkCodeButton.alpha = 1
            checkCodeButton.isEnabled = true
        } else {
            checkCodeButton.alpha = 0.5
            checkCodeButton.isEnabled = false
        }
    }
}
