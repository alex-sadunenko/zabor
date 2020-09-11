//
//  WorkViewController.swift
//  Zabor
//
//  Created by Alex on 07.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class WorkViewController: UIViewController {

    //MARK: - Firebase var
    var user: FUser!
    var ref: DatabaseReference!
    var productArray = [Product]()

    let userDefaults = UserDefaults.standard

    //MARK: - IBOutlet
    @IBOutlet weak var newObjectButton: UIButton!
    @IBOutlet weak var infoObjectTextView: UITextView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = FUser(user: currentUser)
        ref = Database.database().reference(withPath: "products")

        configureNavigation()
        configureAddButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { [weak self] (snapshot) in
            var productArrayTemp = [Product]()
            for item in snapshot.children {
                let product = Product(snapshot: item as! DataSnapshot)
                productArrayTemp.append(product)
            }
            
            self?.productArray = productArrayTemp
            self?.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeAllObservers() 
    }
    
    @IBAction func scanQrCodeTapped(_ sender: UIButton) {
        
    }
    
    // MARK: - Configure Navigation
    func configureNavigation() {
        navigationItem.title = "Подрядчик"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "LogOutFullImage"), style: .plain, target: self, action: #selector(dismissToMainMenu))
        navigationItem.rightBarButtonItem?.tintColor = .darkGray
    }
    
    // MARK: - Configure Add Button
    func configureAddButton() {
        newObjectButton.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
        newObjectButton.layer.cornerRadius = 0.5 * newObjectButton.bounds.size.height
        newObjectButton.clipsToBounds = true
        newObjectButton.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
    }
    
    @objc func dismissToMainMenu() {
        let alert = UIAlertController(title: "Log out", message: "Вы действительно хотите разлогиниться?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            do {
                try Auth.auth().signOut()
                self.userDefaults.set(false, forKey: "isCustomer")
                self.userDefaults.set(false, forKey: "isEmployee")
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let userViewController = mainStoryBoard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
                UIApplication.shared.windows.first?.rootViewController = userViewController
            } catch {
                
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
 
    }
}

// MARK: - Table View Delegate
extension WorkViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = productArray[indexPath.row]
            product.ref?.removeValue()
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Table View Data Source
extension WorkViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ObjectTableViewCell
        cell.descriptionLabel.text = productArray[indexPath.row].description
        cell.dateLabel.text = productArray[indexPath.row].date
        return cell
    }
    
}

