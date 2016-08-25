//
//  StudentInformation.swift

//  PinSample
//
//  Created by Nathan Ho on 8/20/15.
//  Copyright (c) 2015 SomeCompany. All rights reserved.
//

import UIKit

struct StudentInformation {
    var firstName = [String]()
    var lastName = [String]()
    var latitude = [Double]()
    var longitude = [Double]()
    var mediaURL = [String]()
    var uniqueKey = [String]()
    var mapString = [String]()
    
    var appDelegate: AppDelegate!

    init(personDict: NSDictionary) {
        
        var results = [AnyObject]()
        results = personDict["results"] as! [(AnyObject)]
        var numberKey = 0
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        for _ in results {
            let first = results[numberKey]["firstName"] as! String
            firstName.append(first)
            let last = results[numberKey]["lastName"] as! String
            lastName.append(last)
            let mURL = results[numberKey]["mediaURL"] as! String
            mediaURL.append(mURL)
            let specialKey = results[numberKey]["uniqueKey"] as! String
            uniqueKey.append(specialKey)
            let lat = results[numberKey]["latitude"] as! Double
            latitude.append(lat)
            let long = results[numberKey]["longitude"] as! Double
            longitude.append(long)
            let mapLocation = results[numberKey]["mapString"] as! String
            mapString.append(mapLocation)
            StudentData.sharedInstance().mapStrings.append(mapLocation)
            numberKey++
        }
    }
    

    
}


    

