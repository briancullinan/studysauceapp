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

class CardBlankController: UIViewController {
    
    
    @IBOutlet weak var content: AutoSizingTextView? = nil
    
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if content != nil {
                content!.text = vc.card?.content
            }
        }
    }
    
}