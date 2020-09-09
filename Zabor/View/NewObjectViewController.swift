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

class NewObjectViewController: UIViewController, UINavigationControllerDelegate {

    var video = AVCaptureVideoPreviewLayer()
    let session = AVCaptureSession()
    var numberImageTapped = 0
    
    //MARK: - Location var
    var locationManager: CLLocationManager!
    var longitude: Double?
    var latitude: Double?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupVideo()
        startRunning()
    }
    
    //MARK: - IBAction
    @IBAction func photoTapped(_ sender: UIButton) {
        numberImageTapped = sender.tag
        openCamera()
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

//extension NewObjectViewController: UICollectionViewDelegate {
//
//}
//
//extension NewObjectViewController: UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 4
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        cell.backgroundColor = .black
//        return cell
//    }
//}
//
//extension NewObjectViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemsPerRow: CGFloat = 2
//        let paddingWidth = 10 * (itemsPerRow - 1)
//        let availableWidth = collectionView.frame.width - paddingWidth
//        let widthPerItem = availableWidth / itemsPerRow
//        //collectionView.frame.size.height = collectionView.frame.size.width
//
//        return CGSize(width: widthPerItem, height: widthPerItem)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//}
