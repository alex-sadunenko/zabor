//
//  CustomerViewController.swift
//  Zabor
//
//  Created by Alex on 10.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import PDFKit
import FirebaseAuth
import FirebaseDatabase

class CustomerViewController: UIViewController {
    
    //MARK: - Firebase var
    var user: FUser!
    var ref: DatabaseReference!
    var productArray = [Product]()
    
    //MARK: - PDF var
    var pdfView: PDFView!
    
    let userDefaults = UserDefaults.standard
    
    //MARK: - IBOutlet
    @IBOutlet weak var printButton: UIButton! {
        didSet {
            printButton.setShadow()
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBAction func printTapped(_ sender: UIButton) {
        createUI()
        createPDF()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = FUser(user: currentUser)
        ref = Database.database().reference(withPath: "products")
        
        configureNavigation()
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
    
    // MARK: - Configure Navigation
    func configureNavigation() {
        navigationItem.title = "Инвентаризация"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.xmark"), style: .plain, target: self, action: #selector(dismissToMainMenu))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func dismissToMainMenu() {
        let activityViewController = UIActivityViewController(activityItems: [pdfView.document!.dataRepresentation()!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        //view.willRemoveSubview(pdfView)
        
//        // present the view controller
//        self.present(activityViewController, animated: true, completion: nil)
        
//        do {
//            try Auth.auth().signOut()
//            performSegue(withIdentifier: "closeSeque", sender: self)
//        } catch {
//
//        }
//        print("dismissToMainMenu")
//        do {
//            try Auth.auth().signOut()
//            userDefaults.set(false, forKey: "isCustomer")
//            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//            let userViewController = mainStoryBoard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
//            UIApplication.shared.windows.first?.rootViewController = userViewController
//        } catch {
//
//        }
    }
}

// MARK: - Table View Delegate
extension CustomerViewController: UITableViewDelegate {
    
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
extension CustomerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InventoryTableViewCell
        cell.descriptionLabel.text = productArray[indexPath.row].description
        cell.dateLabel.text = productArray[indexPath.row].date
        return cell
    }
}

// MARK: - Create PDF
extension CustomerViewController {
    
    func createUI() {
        pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func createPDF() {
        var tableDataItems = [TableDataItem]()
        for itemIndex in 0..<productArray.count {
            tableDataItems.append(TableDataItem(description: productArray[itemIndex].description, date: productArray[itemIndex].date, userID: productArray[itemIndex].userID))
        }
        let tableDataHeaderTitles =  ["description", "date", "userID"]
        //let sumItem = money.reduce(0, +)
        //tableDataItems.append(TableDataItem(name: "", address: "sum:", money: sumItem))
        
        let pdfCreator = PDFCreator(tableDataItems: tableDataItems, tableDataHeaderTitles: tableDataHeaderTitles)
        
        let data = pdfCreator.create()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
    }
}
