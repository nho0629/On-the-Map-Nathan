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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh(self)
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        ParsingClient.sharedInstance().GETStudentLocationData(pinMapView, parameters: ["limit": 100, "order": "-updatedAt"]) {success, errorString in
            if success {
                print("SUCCESS")
                print(self.appDelegate.mapStrings[0])
            } else {
                self.errorAlert("Failed to Get Data For Map: \(errorString!)", reciever: self)
            }
        }

        
        //1//

        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "pin"), forState: UIControlState.Normal)
        button.addTarget(self, action: "placePin:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 33, 33)
        let pinBarButtonItem = UIBarButtonItem(customView: button)
        
        //2//
        let reloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        //3//
        let logoutBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
        
        navigationItem.setRightBarButtonItems([pinBarButtonItem, reloadBarButtonItem], animated: true)
        navigationItem.setLeftBarButtonItem(logoutBarButtonItem, animated: true)
        
    }
    func placePin(sender: UIBarButtonItem) {
        performSegueWithIdentifier("postingSegue", sender: sender)
    }
    
    // MARK: - MKMapViewDelegate
    
    //Makes Pins//
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
    
    //Opens Pins//
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: (annotationView.annotation?.subtitle!!)!)!)
        }
    }
    
    //Indicates that Map is Loading//
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        mapView.alpha = 0.4
        activityIndicator.startAnimating()
    }
    
    //Asks If the Map has Added the AnnotationViews//
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        mapView.alpha = 1.0
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Using Parsed Data
    func logout(sender: UIBarButtonItem) {
        ParsingClient.sharedInstance().logout(sender) {success, errorString in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.errorAlert("Failed to Logout: \(errorString)", reciever: self)
                print("Failed to Logout")
            }
        }
    }
    
    func refresh(sender: AnyObject) {
        if pinMapView.annotations.isEmpty != true {
            pinMapView?.removeAnnotations((appDelegate?.mapAnnotations)!)
            appDelegate.mapAnnotations.removeAll()
        }
        ParsingClient.sharedInstance().GETStudentLocationData(pinMapView, parameters: ["limit": 100, "order": "-updatedAt"]) {success, errorString in
            if success {
                print("SUCCESS")
                print(self.appDelegate.mapStrings[0])
            } else {
                self.errorAlert("Failed to Get Data For Map: \(errorString!)", reciever: self)
            }
        }
        print("Refreshing")
    }
    
    func errorAlert(errorMessage: String, reciever: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            reciever.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    class func sharedInstance() -> MapViewController {
        
        struct Singleton {
            static var sharedInstance = MapViewController()
        }
        
        return Singleton.sharedInstance
    }
}


