//
//  DataParsing.swift
//  PinSample
//
//  Created by Terence Ho on 12/11/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

class DataParsing {
    
    var newParsedData: NSDictionary!
    
    func parseData(urlDestination: String, addValue1: (value: String, forHTTPHeaderField: String), addValue2: (value: String, forHTTPHeaderField: String), requestMethod: String, requestBody: NSData, reciever: AnyObject, parsedDataType: String) {
        let urlString = urlDestination
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = requestMethod
        request.addValue(addValue1.value, forHTTPHeaderField: addValue1.forHTTPHeaderField)
        request.addValue(addValue2.value, forHTTPHeaderField: addValue2.forHTTPHeaderField)
        request.HTTPBody = requestBody
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    print("error: \(error)")
                    let controller = UIAlertController()
                    controller.title = "Error"
                    controller.message = "No Internet Connection."
                    let errorAction = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Default) { action in reciever.dismissViewControllerAnimated(true, completion: nil)
                    }
                    controller.addAction(errorAction)
                    reciever.presentViewController(controller, animated: true, completion: nil)
                }
                
            }else{
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                if parsedDataType == "newData" {
                let parsedData = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                    self.newParsedData = parsedData
                }else if parsedDataType == "data" {
                    let parsedData = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                    self.newParsedData = parsedData
                }
                
            }
        }
        task.resume()
    }
}

