//
//  ParsingConvienence.swift
//  PinSample
//
//  Created by Terence Ho on 12/18/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

extension ParsingClient {
    
    func login(errorReciever: AnyObject!, jsonBody: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        POSTSessionMethod(jsonBody) {JSONResult, error in
            
            self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            /* 3. Send the desired value(s) to completion handler */
            if let _ = error {
                completionHandler(success: false, errorString: JSONResult["error"] as? String)
            } else {
                if let sessionID = JSONResult["session"]??["id"] as? String {
                    self.appDelegate.sessionID = sessionID
                    if let userID = JSONResult["account"]??["key"] as? String {
                        self.appDelegate.userKey = Int(userID)
                        ParsingClient.sharedInstance().getFullName(){(success, fullName, downloadError) in
                            if fullName?.isEmpty == false {
                                completionHandler(success: true, errorString: nil)
                                
                            }else{
                                completionHandler(success: false, errorString: JSONResult["error"] as? String)
                                print("Failed to obtain user's name")
                            }
                        }
                    }else{
                        completionHandler(success: false, errorString: JSONResult["error"] as? String)
                        print("Failed to get userID")
                    }
                }else{
                    completionHandler(success: false, errorString: JSONResult["error"] as? String)
                    print("Failed to get sessionID")
                }
            
            }
            
            
        }
    }
    
    func logout(sender: AnyObject!, completionHandler: (success: Bool, errorString: String?) -> Void) {
        DELETEMethod(sender) {JSONResult, error in
            if let _ =  error {
                completionHandler(success: false, errorString: "No Internet Connection")
            } else {
                if JSONResult != nil {
                    completionHandler(success: true, errorString: nil)
                }else{
                    completionHandler(success: false, errorString: JSONResult["error"] as? String)
                    print("Failed to Logout")
                }
            }
            
        }
    }
    func GETStudentLocationData(view: AnyObject?, parameters: [String : AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        GETParseMethod(parameters) {JSONResult, error in
            if let _ = error {
                completionHandler(success: false, errorString: JSONResult["error"] as? String)
            }else{
                let locations = StudentInformation(personDict: JSONResult as! NSDictionary)
                
                let results = (JSONResult["results"] as? [(AnyObject)])!
                                
                var numberKey = 0
                
                self.appDelegate.mapAnnotations.removeAll()

                for _ in results {
                    
                    //  Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: locations.latitude[numberKey], longitude: locations.longitude[numberKey])
                    annotation.title = "\(locations.firstName[numberKey]) \(locations.lastName[numberKey])"
                    annotation.subtitle = locations.mediaURL[numberKey]
                    
                    // Finally we place the annotation in an array of annotations.
                    self.appDelegate.mapAnnotations.append(annotation)
                    if view != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            view!.addAnnotations(self.appDelegate.mapAnnotations)
                        }
                    }
                    numberKey++
                    
                }
                if self.appDelegate.userLocation != nil {
                self.appDelegate.mapStrings.append(self.appDelegate.userLocation)
                }
                if self.appDelegate.mapAnnotations.isEmpty != true {
                    completionHandler(success: true, errorString: nil)
                   
                }else{
                    completionHandler(success: false, errorString: "Failed to obtain student location data")
                    print("Failed to obtain student location data")
                }
            }
            
        }
    }
    
    func POSTUserLocationData(jsonBody: String, completionHandler: (success: Bool, errorString: String!) -> Void) {
        POSTParseMethod(jsonBody) {JSONResult, error in
            if let _ = error {
                completionHandler(success: false, errorString: JSONResult["error"] as? String)
            } else {
                completionHandler(success: true, errorString: nil)
                
            }
        
        }
    }
    
    func getFullName(completionHandler: (success: Bool, fullName: String?, errorString: String?) -> Void) {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        GETSessionMethod(appDelegate.userKey) {JSONResult, error in
            if let _ = error {
                completionHandler(success: false, fullName: nil, errorString: JSONResult["error"] as? String)
            }else{
                if let firstName = JSONResult["user"]!!["first_name"] as? String {
                    self.appDelegate.userFirstName = firstName
                    if let lastName = JSONResult["user"]!!["last_name"] as? String {
                        self.appDelegate.userLastName = lastName
                        completionHandler(success: true, fullName: "\(firstName) \(lastName)", errorString: nil)
                    }else{
                        completionHandler(success: false, fullName: nil, errorString: JSONResult["error"] as? String)
                        print("Failed to get fullName")
                    }
                }
            }
            
            
        
        }
    }
    
    
}

