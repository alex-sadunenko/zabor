//
//  NewObjectViewController.swift
//  Zabor
//
//  Created by Alex on 09.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class NewObjectViewController: UIViewController, UINavigationControllerDelegate {

    var video = AVCaptureVideoPreviewLayer()
    let session = AVCaptureSession()
    var numberImageTapped = 0
    
    //MARK: - Location var
    var locationManager: CLLocationManager!
    var longitude: Double?
    var latitude: Double?
    
    var user: FUser!
    var ref: DatabaseReference!
    var date: String!
    
    //MARK: - IBOutlet
    @IBOutlet weak var infoObjectTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoFirst: UIImageView!
    @IBOutlet weak var photoSecond: UIImageView!
    @IBOutlet weak var photoThird: UIImageView!
    @IBOutlet weak var photoFours: UIImageView!
    @IBOutlet weak var buttonFirst: UIButton!
    @IBOutlet weak var buttonSecond: UIButton!
    @IBOutlet weak var buttonThird: UIButton!
    @IBOutlet weak var buttonFours: UIButton!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var dateInstallation: UILabel! {
        didSet {
            let formatter = DateFormatter()
            //formatter.dateStyle = .full
            //formatter.locale = Locale(identifier: "ru")
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateInstallation.text = formatter.string(from: Date() as Date)
            formatter.dateFormat = "yyyyMMddHHmmss"
            date = formatter.string(from: Date() as Date)}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = Auth.auth().currentUser else { return }
        user = FUser(user: currentUser)
        ref = Database.database().reference(withPath: "products")
        
        setupVideo()
        startRunning()
    }
    
    //MARK: - IBAction
    @IBAction func photoTapped(_ sender: UIButton) {
        numberImageTapped = sender.tag
        openCamera()
    }
    @IBAction func cancelTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    @IBAction func saveTapped(_ sender: UIButton) {
        saveData()
    }
    
}

//MARK: - Location
extension NewObjectViewController {
    
    func getСoordinates() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
}

//MARK: - Location Delegate
extension NewObjectViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        guard let latitude = latitude, let longitude = longitude else { return }
        latitudeLabel.text = "Широта: \(latitude)"
        longitudeLabel.text = "Долгота: \(longitude)"
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        getСoordinates()
    }
}

//MARK: - Scan QR
extension NewObjectViewController: AVCaptureMetadataOutputObjectsDelegate {
    
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

//MARK: - Image Picker
extension NewObjectViewController {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Внимание", message: "Проблемы с камерой", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Image Picker Delegate
extension NewObjectViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            switch numberImageTapped {
            case 1:
                photoFirst.image = pickedImage
                buttonFirst.isHidden = true
            case 2:
                photoSecond.image = pickedImage
                buttonSecond.isHidden = true
            case 3:
                photoThird.image = pickedImage
                buttonThird.isHidden = true
            case 4:
                photoFours.image = pickedImage
                buttonFours.isHidden = true
            default:
                return
            }
        }
        picker.dismiss(animated: true, completion: nil)
        getСoordinates()
    }
}

//MARK: - Firebase Save Data
extension NewObjectViewController {
    
    func saveData() {
        let product = Product(userID: user.uid, description: infoObjectTextView.text, date: dateInstallation.text!, latitude: latitude!, longitude: longitude!, isCheck: false, ref: nil)
        let taskRef = ref.child(date)
        taskRef.setValue(["userID": product.userID,
        "description": product.description,
        "date": product.date,
        "latitude": product.latitude,
        "longitude": product.longitude,
        "isCheck": product.isCheck])
    }
}

