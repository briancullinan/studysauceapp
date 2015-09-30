//
//  CardPromptController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/23/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CardPromptController: UIViewController {

    @IBOutlet weak var prompt: UITextView!
    internal var pack: Pack!
    internal var card: Card!
    

    // TODO: check the answer for correctness
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.card = self.pack.getCardForUser((UIApplication.sharedApplication().delegate as! AppDelegate).user)
        self.prompt.text = self.card.content
        self.scalePromptText()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardResponseController {
            vc.card = self.card
            vc.pack = self.pack
        }
    }

    func scalePromptText() -> Void {
        
    }
    
}

