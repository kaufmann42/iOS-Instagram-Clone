/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var activityIndicator: UIActivityIndicatorView!
    var errorsMessage = "Please try again later"
    
    
    @available(iOS 8.0, *)
    func displayAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @available(iOS 8.0, *)
    @IBAction func signUp(sender: AnyObject) {
        
        if username.text == "" || password.text == "" || email.text == "" {
            
            self.displayAlert("Failed Sign Up", message: "Please fill out all feilds")
        } else  {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var user = PFUser()
            
            user.username = username.text
            user.password = password.text
            user.email = email.text
            
            errorsMessage = "Please try again later"
            
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    //log in
                    self.performSegueWithIdentifier("login", sender: self)
                    
                } else {
                    
                    if let errorString = error!.userInfo["error"] as? String {
                        self.errorsMessage = errorString
                    }
                    self.displayAlert("Failed Sign Up", message: self.errorsMessage)
                }
            })
        }
        
    }
    
    @available(iOS 8.0, *)
    @IBAction func login(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(username.text!, password: password.text!) { (user, error) -> Void in
            
            // self.activityIndicator.stopAnimating() <-- thread 1 bad exc
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if user != nil {
                //log in
                self.performSegueWithIdentifier("login", sender: self)
                
                
            } else {
                if let errorString = error!.userInfo["error"] as? String {
                    self.errorsMessage = errorString
                }
                self.displayAlert("Failed Log In", message: self.errorsMessage)
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /*override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
