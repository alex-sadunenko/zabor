//
//  ReportViewController.swift
//  Zabor
//
//  Created by Alex on 10.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ReportViewController: UIViewController {

    //MARK: - Firebase var
    var user: FUser!
    var ref: DatabaseReference!
    var productArray = [Product]()

    //MARK: - Variable
    let searchController = UISearchController(searchResultsController: nil)
    let datePicker = UIDatePicker()
    let userDefaults = UserDefaults.standard
    var filteredProduct = [Product]()
    //    var searchBarIsEmpty: Bool {
    //        guard let text = searchController.searchBar.text else { return false }
//        return text.isEmpty
//    }
//    var isFiltering: Bool { return searchController.isActive && !searchBarIsEmpty }

    //MARK: - IBOutlet
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var checkLabel: UILabel! {
        didSet {
            checkLabel.isHidden = true
        }
    }
    @IBOutlet weak var switchControl: UISwitch! {
        didSet {
            switchControl.isHidden = true
        }
    }
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
        
        configureSearchController()
        configureTextField()

    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
            //navigationItem.searchController = nil

            checkLabel.isHidden = false
            switchControl.isHidden = false
            dateTextField.isHidden = true
        } else {
            checkLabel.isHidden = true
            switchControl.isHidden = true
            dateTextField.isHidden = false
        }
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
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
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeAllObservers()
    }

    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func configureTextField() {
        dateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        
        let tooldar = UIToolbar()
        tooldar.sizeToFit()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        tooldar.setItems([cancelButton,flexSpace,doneButton], animated: true)
        dateTextField.inputAccessoryView = tooldar
    }
    
    @objc func cancelAction() {
        dateTextField.text = ""
        searchController.searchBar.text = ""
        view.endEditing(true)
    }

    @objc func doneAction() {
        getDateFromPicker()
        view.endEditing(true)
    }
    
    func getDateFromPicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: datePicker.date)
        searchController.searchBar.text = formatter.string(from: datePicker.date)
    }

}

//MARK: - Search Controller Delegate
extension ReportViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        switch segmentControl.selectedSegmentIndex {
        case 0:
            filteredProduct = productArray.filter({ (products: Product) -> Bool in
                return products.date.lowercased().contains(searchText.lowercased())
            })
        case 1:
            filteredProduct = productArray.filter({ (products: Product) -> Bool in
                return products.description.lowercased().contains(searchText.lowercased())
            })
        case 2:
            filteredProduct = productArray.filter({ (products: Product) -> Bool in
                return products.description.lowercased().contains(searchText.lowercased())
            })
        default:
            return
        }
        
        tableView.reloadData()
    }
    
}

//MARK: - Table View Delegate
extension ReportViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Table View DataSource
extension ReportViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProduct.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellReportTableViewCell
        switch segmentControl.selectedSegmentIndex {
        case 0:
            cell.nameLabel.text = filteredProduct[indexPath.row].date
            cell.descriptionLabel.text = filteredProduct[indexPath.row].description
        case 1:
            cell.nameLabel.text = filteredProduct[indexPath.row].date
            cell.descriptionLabel.text = filteredProduct[indexPath.row].description
        case 2:
            cell.nameLabel.text = searchController.searchBar.text
            cell.descriptionLabel.text = filteredProduct[indexPath.row].description
        default:
            cell.nameLabel.text = ""
            cell.descriptionLabel.text = ""
        }
        
        return cell
    }
    
}
