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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var mapCoordinate: CLLocationCoordinate2D!
    
    var userAnnotation = [MKPointAnnotation]()
    
    var userLocationString: String!
    
    var appDelegate: AppDelegate!
    
    // MARK: - Initialization
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
        activityIndicator.hidden = true
        
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
    
    // MARK: - Finding locations on the map
    @IBAction func findOnTheMap(sender: UIButton) {
        
        activityIndicator.hidden = false

        self.view.alpha = 0.4
        self.activityIndicator.startAnimating()
        
        userLocationString = locationTextField.text!
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userLocationString, completionHandler: {(placemarks, error)->Void in
            if let placemark = placemarks?[0] as CLPlacemark? {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                self.view.alpha = 1.0
                self.activityIndicator.stopAnimating()
                
                self.activityIndicator.hidden = true
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
                annotation.title = "\(StudentData.sharedInstance().userFirstName) \(StudentData.sharedInstance().userLastName)"
                self.userAnnotation.append(annotation)
                let coordinate = placemark.location?.coordinate
                self.mapView.setCenterCoordinate(coordinate!, animated: false)
                self.mapView.region = self.mapView.regionThatFits(MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(CLLocationDegrees(0.005), CLLocationDegrees(0.005))))
                
                
            }else{
                
                Config.sharedInstance().errorAlert("Unknown Location", receiver: self)
                
                self.view.alpha = 1.0
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                
            }
        })
    }
    
    // MARK: - Textfield formatting
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        linkTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Submitting your location info to map
    @IBAction func SubmitLocation(sender: UIButton) {
        
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
        
        let jsonBody: [String:AnyObject] = [
            "uniqueKey" : String(StudentData.sharedInstance().userKey),
            "firstName" : StudentData.sharedInstance().userFirstName,
            "lastName" : StudentData.sharedInstance().userLastName,
            "mapString" : userLocationString,
            "mediaURL" : linkTextField.text!,
            "latitude" : mapCoordinate!.latitude as Double ,
            "longitude" : mapCoordinate!.longitude as Double ]
        
        ParsingClient.sharedInstance().POSTUserLocationData(self, jsonBody: jsonBody) {(success, errorString) in
            if success {
                
                StudentData.sharedInstance().userLocation = self.userLocationString
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)

                    self.userAnnotation[0].subtitle = StudentData.sharedInstance().userLocation
                }
            }else{
                Config.sharedInstance().errorAlert("Failed to place pin", receiver: self)

            }
        }
        }

    
}

