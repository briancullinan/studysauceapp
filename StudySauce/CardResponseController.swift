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

class CardResponseController: UIViewController {
    
    internal var pack: Pack!
    internal var cards = [Card]()
    internal var card: Card!
    
    @IBOutlet internal weak var response: UITextView!
    // TODO: control which card comes next using local store
    
    // TODO: Store response in the database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.response.text = self.card.response
    }
}

