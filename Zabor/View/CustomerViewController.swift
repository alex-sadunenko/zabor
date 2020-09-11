//
//  CustomerViewController.swift
//  Zabor
//
//  Created by Alex on 10.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import PDFKit
import AVFoundation
import FirebaseAuth
import FirebaseDatabase

class CustomerViewController: UIViewController {
    
    //MARK: - Firebase var
    var user: FUser!
    var ref: DatabaseReference!
    var productArray = [Product]()
    
    //MARK: - PDF var
    var pdfView: PDFView!
    
    //MARK: - QR var
    var video = AVCaptureVideoPreviewLayer()
    var session = AVCaptureSession()

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
    
    //MARK: - IBAction
    @IBAction func printTapped(_ sender: UIButton) {
        session = AVCaptureSession()
        setupVideo()
        startRunning()
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
}

// MARK: - Configure Navigation and Activity
extension CustomerViewController {

    func configureNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "printer"), style: .plain, target: self, action: #selector(createFilePDF))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func createFilePDF() {
        createUI()
        createPDF()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareFilePDF))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "x.circle"), style: .plain, target: self, action: #selector(closeFilePDF))
        navigationItem.leftBarButtonItem?.tintColor = .black

    }
    
    @objc func closeFilePDF() {
        
        guard  let sublayers = view.layer.sublayers else { return }
        
        for layer in sublayers {
            if (layer.delegate!.description).contains("PDFView") {
                layer.removeFromSuperlayer()
            }
        }
        //view.layer.sublayers?.removeLast()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "printer"), style: .plain, target: self, action: #selector(self.createFilePDF))
        navigationItem.rightBarButtonItem?.tintColor = .black

        navigationItem.leftBarButtonItem = nil
        
    }

    @objc func shareFilePDF() {
        
        let activityViewController = UIActivityViewController(activityItems: [pdfView.document!.dataRepresentation()!], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.view.layer.sublayers?.removeLast()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "printer"), style: .plain, target: self, action: #selector(self.createFilePDF))
                self.navigationItem.rightBarButtonItem?.tintColor = .black
            }
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
}

// MARK: - Table View Delegate
extension CustomerViewController: UITableViewDelegate {
        
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
        
        if productArray[indexPath.row].isCheck {
            cell.accessoryType = .checkmark
            cell.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            productArray[indexPath.row].ref?.updateChildValues(["isCheck": true])
        } else {
            cell.accessoryType = .none
            cell.backgroundColor = .none
        }
        
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

//MARK: - Scan QR
extension CustomerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func setupVideo() {
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
    }
    
    func startRunning() {
        view.layer.addSublayer(video)
        session.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else { return }
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == AVMetadataObject.ObjectType.qr {
                
                let alert = UIAlertController(title: "Объект", message: object.stringValue, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    let findObject = object.stringValue
                    self.view.layer.sublayers?.removeLast()
                    self.session.stopRunning()
                    self.findInProductArray(product: findObject)
                }
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                present(alert, animated: true)
            }
        }
    }
    
    func findInProductArray(product: String?) {
        guard let product = product else { return }
        for item in 0..<productArray.count {
            if product == productArray[item].description {
                productArray[item].isCheck = true
                tableView.reloadData()
                break
            }
        }
    }
}
