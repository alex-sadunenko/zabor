//
//  WorkViewController.swift
//  Zabor
//
//  Created by Alex on 07.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth

class WorkViewController: UIViewController {

    @IBOutlet weak var newObjectButton: UIButton!
    @IBOutlet weak var infoObjectTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        configureAddButton()
        
    }
    
    @IBAction func scanQrCodeTapped(_ sender: UIButton) {
        
    }
    
    // MARK: - Configure Navigation

    func configureNavigation() {
        //navigationController?.navigationBar.barTintColor = .darkGray
        //navigationController?.navigationBar.barStyle = .default
        navigationItem.title = "Подрядчик"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.xmark"), style: .plain, target: self, action: #selector(dismissToMainMenu))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    // MARK: - Configure Add Button
    
    func configureAddButton() {
        newObjectButton.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
        newObjectButton.layer.cornerRadius = 0.5 * newObjectButton.bounds.size.height
        newObjectButton.clipsToBounds = true
        newObjectButton.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
    }
    
    @objc func dismissToMainMenu() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "closeSeque", sender: self)
        } catch {
            
        }
        print("dismissToMainMenu")
    }
}

extension WorkViewController: UITableViewDelegate {
    
}

extension WorkViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ObjectTableViewCell
        return cell
    }
    
}

