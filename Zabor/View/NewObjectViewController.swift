//
//  NewObjectViewController.swift
//  Zabor
//
//  Created by Alex on 09.09.2020.
//  Copyright © 2020 Alex Sadunenko. All rights reserved.
//

import UIKit
import AVFoundation

class NewObjectViewController: UIViewController {

    var video = AVCaptureVideoPreviewLayer()
    let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupVideo()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
