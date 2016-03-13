//
//  InformationPostingViewController.swift
//  PinSample
//
//  Created by Terence Ho on 9/27/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var mapCoordinate: CLLocationCoordinate2D!
    
    var userAnnotation = [MKPointAnnotation]()
    
    var userLocationString: String!
    
    var appDelegate: AppDelegate!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        linkTextField.delegate = self
        locationTextField.delegate = self
        
        linkTextField.hidden = true
        linkTextField.enabled = false
        mapView.hidden = true
        submitButton.hidden = true
        submitButton.enabled = false
        mapView.zoomEnabled = false
        
        appDelegate.userLocation = userLocationString
        
    }
    
    override func viewWillAppear(animated: Bool) {
        Config.sharedInstance().subscribeToKeyboardNotifications(self.view)
    }
    
    override func viewWillDisappear(animated: Bool) {
        Config.sharedInstance().unsubscribeToKeyboardNotifications(self.view)
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: UIButton) {
        userLocationString = locationTextField.text!
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userLocationString, completionHandler: {(placemarks, error)->Void in
            if let placemark = placemarks?[0] as CLPlacemark? {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                
                self.locationTextField.hidden = true
                self.locationTextField.enabled = false
                self.linkTextField.hidden = false
                self.linkTextField.enabled = true
                self.mapView.hidden = false
                self.topLabel.hidden = true
                self.topLabel.textColor = UIColor.whiteColor()
                self.submitButton.hidden = false
                self.submitButton.enabled = true
                self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: [])
                self.colorView.backgroundColor = self.backgroundView.backgroundColor
                self.mapView.zoomEnabled = true
                
                self.mapCoordinate = placemark.location!.coordinate
                
                //  Here we create the annotation and set its coordiate, title, and subtitle properties
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = self.mapCoordinate
                annotation.title = "\(self.appDelegate.userFirstName) \(self.appDelegate.userLastName)"
                self.userAnnotation.append(annotation)
                let coordinate = placemark.location?.coordinate
                self.mapView.setCenterCoordinate(coordinate!, animated: false)
                self.mapView.region = self.mapView.regionThatFits(MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(CLLocationDegrees(0.005), CLLocationDegrees(0.005))))
                
                
            }else{
                
                self.errorAlert("Unknown Location", reciever: self)
                
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        linkTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dismissedSegue" {
        
            locationTextField.hidden = false
            locationTextField.enabled = true
            locationTextField.text! = ""
            linkTextField.hidden = true
            linkTextField.enabled = false
            cancelButton.setTitleColor(UIColor.blueColor(), forState: [])
            mapView.hidden = true
            topLabel.hidden = false
            topLabel.textColor = UIColor.blackColor()
            submitButton.hidden = true
            submitButton.enabled = false
            colorView.backgroundColor = bottomView.backgroundColor
            mapView.zoomEnabled = false
        }
    }
    
    
    @IBAction func SubmitLocation(sender: UIButton) {
        ParsingClient.sharedInstance().POSTUserLocationData("{\"uniqueKey\": \"\(appDelegate.userKey)\", \"firstName\": \"\(appDelegate.userFirstName)\", \"lastName\": \"\(appDelegate.userLastName)\",\"mapString\": \"\(userLocationString)\", \"mediaURL\": \"\(linkTextField.text!)\",\"latitude\": \(mapCoordinate.latitude), \"longitude\": \(mapCoordinate.latitude)}") {(success, errorString) in
            if success {
                print(self.userLocationString)
               // self.appDelegate.mapStrings.append(self.appDelegate.userLocation)
                dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("dismissedSegue", sender: self.submitButton)
                    self.userAnnotation[0].subtitle = self.appDelegate.userLocation
                    print(self.userAnnotation[0].subtitle)
                    self.appDelegate.mapAnnotations.append(self.userAnnotation[0])
                    self.appDelegate.userLocation = self.userLocationString
                }
            }else{
                self.errorAlert("Failed to place pin", reciever: self)
            }
        }
        }
    func errorAlert(errorMessage: String, reciever: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            reciever.presentViewController(alert, animated: true, completion: nil)
            
        }
    }

    
}

