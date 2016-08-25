//
//  MapViewController.swift
//  PinSample
//
//  Created by Nathan Ho on 3/23/15.
//  Copyright (c) 2015 SomeCompany. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var pinMapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let session = NSURLSession.sharedSession()
    
    var annotations = [MKPointAnnotation]()
    
    var appDelegate: AppDelegate!
    
    var userLocation: String!
    
    // MARK: - Initialization
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh(self)
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        ParsingClient.sharedInstance().GETStudentLocationData(self, view: pinMapView, parameters: ["limit": 100, "order": "-updatedAt"]) {success, errorString in
            if success {
                print("Success: Loaded pins")
            } else {
                Config.sharedInstance().errorAlert("Failed to Get Data For Map: \(errorString!)", receiver: self)
            }
        }

        

        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "pin"), forState: UIControlState.Normal)
        button.addTarget(self, action: "placePin:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 33, 33)
        let pinBarButtonItem = UIBarButtonItem(customView: button)
        
        let reloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")

        let logoutBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
        
        navigationItem.setRightBarButtonItems([pinBarButtonItem, reloadBarButtonItem], animated: true)
        navigationItem.setLeftBarButtonItem(logoutBarButtonItem, animated: true)
        
    }
    func placePin(sender: UIBarButtonItem) {
        performSegueWithIdentifier("postingSegue", sender: sender)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: (annotationView.annotation?.subtitle!!)!)!)
        }
    }
    
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        mapView.alpha = 0.4
        activityIndicator.startAnimating()
    }
    
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        mapView.alpha = 1.0
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Using Parsed Data
    func logout(sender: UIBarButtonItem) {
        ParsingClient.sharedInstance().logout(sender) {success, errorString in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                Config.sharedInstance().errorAlert("Failed to Logout: \(errorString)", receiver: self)
                print("Failed to Logout")
            }
        }
    }
    
    func refresh(sender: AnyObject) {
        if pinMapView.annotations.isEmpty != true {
            pinMapView?.removeAnnotations((StudentData.sharedInstance().mapAnnotations))
           StudentData.sharedInstance().mapAnnotations.removeAll()
        }
        ParsingClient.sharedInstance().GETStudentLocationData(self, view: pinMapView, parameters: ["limit": 100, "order": "-updatedAt"]) {success, errorString in
            if success {
                print("SUCCESS")
            } else {
                Config.sharedInstance().errorAlert("Failed to Get Data For Map: \(errorString!)", receiver: self)
            }
        }
        print("Refreshing")
    }
    
    class func sharedInstance() -> MapViewController {
        
        struct Singleton {
            static var sharedInstance = MapViewController()
        }
        
        return Singleton.sharedInstance
    }
}


