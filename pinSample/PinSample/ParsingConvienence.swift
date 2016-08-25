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
    
    // MARK: - Logs in
    func login(errorReceiver: AnyObject!, jsonBody: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        POSTSessionMethod(errorReceiver, jsonBody: jsonBody) {JSONResult, error in
            
            self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            if let _ = error {
                completionHandler(success: false, errorString: "No internet Connection.")
            } else {
                if let sessionID = JSONResult["session"]??["id"] as? String {
                    StudentData.sharedInstance().sessionID = sessionID
                    if let userID = JSONResult["account"]??["key"] as? String {
                        StudentData.sharedInstance().userKey = Int(userID)
                        ParsingClient.sharedInstance().getFullName(errorReceiver){(success, fullName, downloadError) in
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
    
    // MARK: - Logs out
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
    
    // MARK: - Gets data for pins on the map
    func GETStudentLocationData(receiver: AnyObject!, view: AnyObject?, parameters: [String : AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        GETParseMethod(receiver, parameters: parameters) {JSONResult, error in
            if let _ = error {
                completionHandler(success: false, errorString: JSONResult["error"] as? String)
            }else{
                let locations = StudentInformation(personDict: JSONResult as! NSDictionary)
                
                let results = (JSONResult["results"] as? [(AnyObject)])!
                                
                var numberKey = 0
                
                StudentData.sharedInstance().mapAnnotations.removeAll()

                for _ in results {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: locations.latitude[numberKey], longitude: locations.longitude[numberKey])
                    annotation.title = "\(locations.firstName[numberKey]) \(locations.lastName[numberKey])"
                    annotation.subtitle = locations.mediaURL[numberKey]
                    StudentData.sharedInstance().mapAnnotations.append(annotation)
                    if view != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            view!.addAnnotations(StudentData.sharedInstance().mapAnnotations)
                        }
                    }
                    numberKey++
                    
                }
                if StudentData.sharedInstance().userLocation != nil {
                StudentData.sharedInstance().mapStrings.append(StudentData.sharedInstance().userLocation)
                }
                if StudentData.sharedInstance().mapAnnotations.isEmpty != true {
                    completionHandler(success: true, errorString: nil)
                   
                }else{
                    completionHandler(success: false, errorString: "Failed to obtain student location data")
                    print("Failed to obtain student location data")
                }
            }
            
        }
    }
    
    // MARK: - POSTs user's data to the map
    func POSTUserLocationData(receiver: AnyObject!, jsonBody: [String:AnyObject], completionHandler: (success: Bool, errorString: String!) -> Void) {
        POSTParseMethod(receiver, httpBody: jsonBody) {JSONResult, error in
            if let _ = error {
                completionHandler(success: false, errorString: JSONResult["error"] as? String)
            } else {
                completionHandler(success: true, errorString: nil)
                
            }
        
        }
    }
    
    // MARK: - Gets the fullname of the user 
    func getFullName(receiver: AnyObject!, completionHandler: (success: Bool, fullName: String?, errorString: String?) -> Void) {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        GETSessionMethod(receiver, parameter: StudentData.sharedInstance().userKey) {JSONResult, error in
            if let _ = error {
                completionHandler(success: false, fullName: nil, errorString: JSONResult["error"] as? String)
            }else{
                if let firstName = JSONResult["user"]!!["first_name"] as? String {
                    StudentData.sharedInstance().userFirstName = firstName
                    if let lastName = JSONResult["user"]!!["last_name"] as? String {
                        StudentData.sharedInstance().userLastName = lastName
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

