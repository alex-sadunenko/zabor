//
//  MapViewController.swift
//  Zabor
//
//  Created by Alex on 10.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class MapViewController: UIViewController {

    //MARK: - Firebase var
    var user: FUser!
    var ref: DatabaseReference!
    var productArray = [Product]()

    //MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.clearsContextBeforeDrawing = true
            mapView.delegate = self
        }
    }
    
    let userDefaults = UserDefaults.standard

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
            self?.addAnnotation()
        })
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeAllObservers()
    }

}

// MARK: - Configure Navigation
extension MapViewController {
    
    func configureNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "LogOutFullImage"), style: .plain, target: self, action: #selector(dismissToMainMenu))
        navigationItem.rightBarButtonItem?.tintColor = .darkGray
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

//MARK: - Map Kit Delegate
extension MapViewController: MKMapViewDelegate {
    
    func addAnnotation() {
        var annotationArray = [MKPointAnnotation]()
        var annotation = MKPointAnnotation()
        for item in 0..<productArray.count {
            annotation = MKPointAnnotation()
            annotation.title = productArray[item].description
            annotation.subtitle = productArray[item].date
            annotation.coordinate = CLLocationCoordinate2D(latitude: productArray[item].latitude, longitude: productArray[item].longitude)
            annotation.accessibilityLabel = "\(productArray[item].isCheck)"
            annotationArray.append(annotation)
        }
        mapView.showAnnotations(annotationArray, animated: true)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            if let annotationPoint = annotation as? MKPointAnnotation {
                if annotationPoint.accessibilityLabel == "true" {
                    annotationView?.pinTintColor = .green
                } else {
                    annotationView?.pinTintColor = .orange
                }
            }
        }
        
        return annotationView
    }
}
