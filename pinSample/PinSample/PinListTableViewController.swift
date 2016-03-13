//
//  PinListTableViewController.swift
//  PinSample
//
//  Created by Terence Ho on 10/10/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

class PinListTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var pinTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var appDelegate: AppDelegate!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        refresh(self)
        
        //1//
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "pin"), forState: UIControlState.Normal)
        button.addTarget(self, action: "placePin:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 33, 33)
        
        let pinBarButtonItem = UIBarButtonItem(customView: button)
        
        //2//
        let reloadButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        
        //3//
        let logoutBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
        
        self.navigationItem.setRightBarButtonItems([pinBarButtonItem, reloadButtonItem], animated: true)
        self.navigationItem.setLeftBarButtonItem(logoutBarButtonItem, animated: true)
        
    }
    
    func placePin(sender: UIBarButtonItem) {
        performSegueWithIdentifier("postingSegue", sender: sender)
    }

    
    func logout(sender: UIBarButtonItem) {
        ParsingClient.sharedInstance().logout(sender) {success, errorString in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                self.errorAlert(errorString!, reciever: self)
            }
            
            
        }
    }
    
    func refresh(sender: AnyObject) {
        ParsingClient.sharedInstance().GETStudentLocationData(nil, parameters: ["limit": 100, "order": "-updatedAt"]) {success, errorString in
            if success {
               // self.appDelegate.mapStrings.append(self.appDelegate.userLocation)
                self.pinTableView?.reloadData()
                
                print("refreshing")
            }else{
              self.errorAlert(errorString!, reciever: self)
            }
        }
    }

    // MARK: - TableView Functions
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.mapAnnotations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomPinCell") as! CustomPinCell
        cell.name.text = appDelegate.mapAnnotations[indexPath.row].title
        cell.mediaURL.text = appDelegate.mapAnnotations[indexPath.row].subtitle
        cell.location.text = appDelegate.mapStrings[indexPath.row]
        
        return cell
    }
    
    override  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: appDelegate.mapAnnotations[indexPath.row].subtitle!)!)
        
    }
    
    func errorAlert(errorMessage: String, reciever: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            reciever.presentViewController(alert, animated: true, completion: nil)
            
        }

    }

}
