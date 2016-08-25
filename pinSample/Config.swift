//
//  Config.swift
//  PinSample
//
//  Created by Terence Ho on 12/11/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

class Config {
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    func subscribeToKeyboardNotifications(reciever: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(reciever, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: reciever)
        NSNotificationCenter.defaultCenter().addObserver(reciever, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: reciever)
    }
    
    func unsubscribeToKeyboardNotifications(reciever: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(reciever, name: UIKeyboardWillShowNotification, object: reciever)
        NSNotificationCenter.defaultCenter().removeObserver(reciever, name: UIKeyboardWillHideNotification, object: reciever)
    }
    
    func keyboardWillShow(notification: NSNotification, reciever: AnyObject) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            reciever.view!!.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification, reciever: AnyObject) {
        
        if keyboardAdjusted == true {
            reciever.view!!.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func errorAlert(errorMessage: String, receiver: AnyObject) {
            dispatch_async(dispatch_get_main_queue()) {
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                receiver.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
        
    
    class func sharedInstance() -> Config {
        
        struct Singleton {
            static var sharedInstance = Config()
        }
        
        return Singleton.sharedInstance
    }
    
    
}