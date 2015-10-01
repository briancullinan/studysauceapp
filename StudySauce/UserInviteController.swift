//
//  UserInviteController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserInviteController : UIViewController {
    
    @IBOutlet weak var code: UITextField!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserRegisterController {
            vc.registrationCode = code.text
        }
    }
    

}