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

    @IBOutlet weak var countLabel: UILabel!
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
        let index = self.pack.getIndexForCard(self.card, user: AppDelegate.getUser())
        let count = self.pack.getCardCount(AppDelegate.getUser())
        self.countLabel.text = "\(index) of \(count)"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardResponseController {
            vc.card = self.card
            vc.pack = self.pack
        }
    }
    
}

