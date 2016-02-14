//
//  DetailViewController.swift
//  Yelp
//
//  Created by Difan Chen on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var businessToDisplay: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(centerLocation)
        for business in businessToDisplay {
            let coordinate = CLLocationCoordinate2D(latitude: Double(business.latitude!), longitude: Double(business.longitude!))
            let title = business.name
            let categories = business.categories
            addAnnotationAtCoordinate(coordinate, busineessTitle: title!, categories: categories!)
        }
    }
    @IBAction func onReturnButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, busineessTitle: String, categories: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = busineessTitle
        annotation.subtitle = categories
        mapView.addAnnotation(annotation)
    }
}
