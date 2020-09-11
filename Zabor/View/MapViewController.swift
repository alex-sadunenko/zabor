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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        addAnnotation()
        configureNavigation()
    }

}

// MARK: - Configure Navigation
extension MapViewController {
    
    func configureNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "lock.circle"), style: .plain, target: self, action: #selector(dismissToMainMenu))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func dismissToMainMenu() {
        let alert = UIAlertController(title: "Log out", message: "Вы действительно хотите разлогиниться?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            do {
//                try Auth.auth().signOut()
//                self.userDefaults.set(false, forKey: "isCustomer")
//                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//                let userViewController = mainStoryBoard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
//                UIApplication.shared.windows.first?.rootViewController = userViewController
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
        let annotation = MKPointAnnotation()
        annotation.title = "Урна"
        annotation.subtitle = "02.23.2020"
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: 48.480444308953864, longitude: 35.07086296581906)
        mapView.showAnnotations([annotation], animated: true)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.pinTintColor = .green
        }
        
        return annotationView
    }
}
