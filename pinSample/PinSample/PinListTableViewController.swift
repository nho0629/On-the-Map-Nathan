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
    
    // MARK: - Initialization
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        refresh(self)
        
        ParsingClient.sharedInstance().GETStudentLocationData(self, view: nil, parameters: ["limit": 100, "order": "-updatedAt"]) {success, errorString in
            if success {
                print("Success: Loaded table cells")
                
                if StudentData.sharedInstance().userLocation != nil {
                StudentData.sharedInstance().mapStrings.insert(StudentData.sharedInstance().userLocation, atIndex: 0)
                    print("Successfully added user location to mapStrings")
                }
            }else{
                Config.sharedInstance().errorAlert(errorString!, receiver: self)
            }
        }
        
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
    
    // MARK: - Parsing
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
        ParsingClient.sharedInstance().GETStudentLocationData(self, view: nil, parameters: ["limit": 100, "order": "-updatedAt"]) {success, errorString in
            if success {
                self.pinTableView?.reloadData()
                print("refreshing")
            }else{
                Config.sharedInstance().errorAlert(errorString!, receiver: self)
            }
        }
    }
    
    // MARK: - TableView Functions
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return StudentData.sharedInstance().mapAnnotations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomPinCell") as! CustomPinCell
        
        cell.name.text = StudentData.sharedInstance().mapAnnotations[indexPath.row].title
        cell.location.text = StudentData.sharedInstance().mapStrings[indexPath.row]
        
        print(cell.location.text)
        
        cell.mediaURL.text = StudentData.sharedInstance().mapAnnotations[indexPath.row].subtitle
        
        return cell
    }
    
    override  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: StudentData.sharedInstance().mapAnnotations[indexPath.row].subtitle!)!)
        
    }
    
}