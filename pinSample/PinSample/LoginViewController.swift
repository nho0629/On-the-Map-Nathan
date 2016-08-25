//
//
//  LoginViewController.swift
//  PinSample
//
//  Created by Nathan Ho on 8/23/15.
//  Copyright (c) 2015 someCompany. All rights reserved.
//
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer?
    
    var udacity: AnyObject!
    
    var parsingClient: ParsingClient!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.text! = "peter.ho433@gmail.com"
        passwordTextField.text! = "xanthosis"
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        session = NSURLSession.sharedSession()
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Config.sharedInstance().subscribeToKeyboardNotifications(LoginViewController)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        Config.sharedInstance().unsubscribeToKeyboardNotifications(LoginViewController)
    }
    
    // MARK: - Keyboard Fixes
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        return true
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpButtun(sender: UIButton) {
        let signupURL = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string:signupURL)!)
    }
    
    // MARK: - Login
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        if usernameTextField.text!.isEmpty {
        Config.sharedInstance().errorAlert("Username is empty.", receiver: self)
        
        }else if passwordTextField.text!.isEmpty {
             Config.sharedInstance().errorAlert("Password is empty.", receiver: self)
        } else {
            ParsingClient.sharedInstance().login(self, jsonBody: "{\"udacity\": {\"username\": \"\(usernameTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}"){ (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                Config.sharedInstance().errorAlert("Login Failed: \(errorString!)", receiver: self)
                }
            }

        }
    }
    
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
        }
    }
    
    

    
    
    }

