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
        setupVideo()
        
    }
    
    @IBAction func scanQrCodeTapped(_ sender: UIButton) {
        startRunning()
    }
    
    // MARK: - Configure Navigation

    func configureNavigation() {
        //navigationController?.navigationBar.barTintColor = .darkGray
        //navigationController?.navigationBar.barStyle = .default
        navigationItem.title = "Подрядчик"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.xmark"), style: .plain, target: self, action: #selector(dismissToMainMenu))
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

//MARK: - Scan QR

extension WorkViewController: AVCaptureMetadataOutputObjectsDelegate {
    
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
                    self.infoObjectTextView.text = object.stringValue
                    self.view.layer.sublayers?.removeLast()
                    self.session.stopRunning()
                }
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                present(alert, animated: true)
                
            }
        }
    }
}
