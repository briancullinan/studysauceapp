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

class CardSelfController: UIViewController {
    
    
    @IBOutlet weak var correctButton: UIButton? = nil
    @IBOutlet weak var wrongButton: UIButton? = nil
    weak var card: Card? = nil
    
    @IBAction func returnToPrompt(_ segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let pvc = self.parent as? CardController {
            self.card = pvc.card
            if let vc = segue.destination as? CardPromptController {
                vc.card = self.card
            }
            if let vc = segue.destination as? CardResponseController {
                vc.card = self.card
            }
        }
    }
    
    func submitResponse(_ correct: Bool) {
        self.correctButton?.isEnabled = false
        self.wrongButton?.isEnabled = false
        if let vc = self.parent as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                newResponse.correct = correct as NSNumber?
                newResponse.card = self.card
                newResponse.created = Date()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                vc.intermediateResponse = newResponse.correct == 1
                doMain {
                    self.performSegue(withIdentifier: "card", sender: self)
                }
                HomeController.syncResponses(self.card!.pack!)
            }
        }
    }
        
    @IBAction func wrongClick(_ sender: UIButton) {
        self.submitResponse(false)
    }
    
    @IBAction func correctClick(_ sender: UIButton) {
        self.submitResponse(true)
    }
}
