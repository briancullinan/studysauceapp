//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserRegisterController : UIViewController {
    
    internal var registrationCode: String?
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var childSwitch: UISwitch!
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    
    @IBAction func childSwitchOn(sender: AnyObject) {
        
        if childSwitch.on
        {
            childFirst.hidden = false
            childLast.hidden = false
        }
        
        else
        {
            childFirst.hidden = true
            childLast.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.registrationCode != nil {
            self.getInvite()
        }
    }
    
    func getInvite() -> Void {
        let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/invite/\(self.registrationCode!)")!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                dispatch_async(dispatch_get_main_queue(), {
                    self.firstName.text = json["first"] as? String
                    self.lastName.text = json["last"] as? String
                    self.email.text = json["email"] as? String
                })
            }
            catch _ as NSError {
                
            }
        })
        task.resume()
    }
}