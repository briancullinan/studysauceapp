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

class CardTrueFalseController: UIViewController {
    
    weak var card: Card? = nil
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var falseButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = self.parent as? CardController {
            self.card = vc.card
        }
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
    
    func saveResponse(_ value: String) {
        self.trueButton.isEnabled = false
        self.falseButton.isEnabled = false
        if let vc = self.parent as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                for a in self.card!.answers!.allObjects as! [Answer] {
                    if a.value == value {
                        let ex = try? NSRegularExpression(pattern: a.value!, options: [NSRegularExpression.Options.caseInsensitive])
                        let match = ex?.firstMatch(in: value, options: [], range:NSMakeRange(0, value.characters.count))
                        newResponse.correct = match != nil ? 1 : 0
                        newResponse.answer = a
                        break
                    }
                }
                newResponse.value = value
                newResponse.card = self.card
                newResponse.created = Date()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                // store intermediate and don't call this until after the correct answer is shown
                vc.intermediateResponse = newResponse.correct == 1
                doMain {
                    self.performSegue(withIdentifier: "correct", sender: self)
                }
                HomeController.syncResponses(self.card!.pack!)
            }
        }
    }
    
    @IBAction func falseClick(_ sender: UIButton) {
        self.saveResponse("false")
    }
    
    @IBAction func trueClick(_ sender: UIButton) {
        self.saveResponse("true")
    }
}
