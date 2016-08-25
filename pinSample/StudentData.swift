//
//  StudentData.swift
//  PinSample
//
//  Created by Terence Ho on 6/23/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import MapKit

class StudentData {
    
    var sessionID: AnyObject? = nil
    
    var locationString = [String]()
    var userFirstName: String!
    var userLastName: String!
    var userKey: Int!
    var userLocation: String!
    
    var mapAnnotations = [MKPointAnnotation]()
    var mapStrings = [String]()
    
    var locations = [StudentInformation]()
    
    
    class func sharedInstance() -> StudentData {
        
        struct Singleton {
            static var sharedInstance = StudentData()
        }
        
        return Singleton.sharedInstance
    }
    
}
