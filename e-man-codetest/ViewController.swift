//
//  ViewController.swift
//  e-man-codetest
//
//  Created by Nigel Stuckey on 25/07/2016.
//  Copyright © 2016 Alex Stuckey. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let camera = GMSCameraPosition.cameraWithLatitude(51.5215201,
                                                          longitude: -0.1421055,
                                                          zoom: 17)
        let mapView = GMSMapView.mapWithFrame(.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
        
        let eManMarker = GMSMarker()
        eManMarker.position = CLLocationCoordinate2DMake(51.5215201, -0.1421055)
        eManMarker.title = "E-Man"
        eManMarker.snippet = "Fitzrovia"
        eManMarker.icon = UIImage(named: "map_pins.png")
        eManMarker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
//    MARK: GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        mapView.clear()
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        self.performSegueWithIdentifier("ShowFlickrCol", sender: self)
        return false
    }
    

}

