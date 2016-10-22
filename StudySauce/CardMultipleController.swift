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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CardMultipleController: UIViewController {

    
    @IBOutlet weak var answer1: UIButton? = nil
    @IBOutlet weak var answer2: UIButton? = nil
    @IBOutlet weak var answer3: UIButton? = nil
    @IBOutlet weak var answer4: UIButton? = nil
    weak var card: Card? = nil
    
    @IBAction func returnToMultiple(_ segue: UIStoryboardSegue) {
        
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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let pvc = self.parent as? CardController {
            self.card = pvc.card
            if self.answer1 != nil && self.card?.answers?.count > 0 {
                self.answer1!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer1!.setTitle((self.card?.answers!.allObjects[0] as! Answer).value, for: UIControlState())
            }
            if self.answer2 != nil && self.card?.answers?.count > 1 {
                self.answer2!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer2!.setTitle((self.card?.answers!.allObjects[1] as! Answer).value, for: UIControlState())
            }
            if self.answer3 != nil && self.card?.answers?.count > 2 {
                self.answer3!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer3!.setTitle((self.card?.answers!.allObjects[2] as! Answer).value, for: UIControlState())
            }
            if self.answer4 != nil && self.card?.answers?.count > 3 {
                self.answer4!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer4!.setTitle((self.card?.answers!.allObjects[3] as! Answer).value, for: UIControlState())
            }
        }
    }
    
    func saveResponse(_ value: String) {
        self.answer1?.isEnabled = false
        self.answer2?.isEnabled = false
        self.answer3?.isEnabled = false
        self.answer4?.isEnabled = false
        if let vc = self.parent as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                for a in self.card!.answers!.allObjects as! [Answer] {
                    if a.value == value {
                        newResponse.correct = a.correct
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
    
    @IBAction func answer1Click(_ sender: UIButton) {
        self.saveResponse(sender.title(for: UIControlState())!)
    }
    
    @IBAction func answer2Click(_ sender: UIButton) {
        self.saveResponse(sender.title(for: UIControlState())!)
    }
    
    @IBAction func answer3Click(_ sender: UIButton) {
        self.saveResponse(sender.title(for: UIControlState())!)
    }
    
    @IBAction func answer4Click(_ sender: UIButton) {
        self.saveResponse(sender.title(for: UIControlState())!)
    }
}
