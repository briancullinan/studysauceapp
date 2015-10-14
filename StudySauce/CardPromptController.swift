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

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var packTitle: UILabel!
    @IBOutlet weak var prompt: UITextView!
    internal var pack: Pack!
    internal var card: Card!
    

    // TODO: check the answer for correctness
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.card = self.pack.getCardForUser(AppDelegate.getUser())
        self.prompt.text = self.card.content
        self.packTitle.text = self.pack.title
        if let url = self.pack.logo where !url.isEmpty {
            let logo = UIImage(data: NSData(contentsOfURL: NSURL(string:url)!)!)!
            self.logoImage.image = logo
        }
        else {
            self.logoImage.image = nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardResponseController {
            vc.card = self.card
            vc.pack = self.pack
        }
    }
    
}

