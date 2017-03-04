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

class CardController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var packTitle: UILabel!
    @IBOutlet weak var embeddedView: UIView!
    internal var intermediateResponse: Bool? = nil
    internal var pack: Pack!
    internal var card: Card? = nil
    internal var subview: UIViewController? = nil {
        didSet {
            self.addChildViewController(self.subview!)
            self.subview!.didMove(toParentViewController: self)
        }
    }
    internal var isRetention = false
    internal var selectedPack: Pack? = nil

    @IBAction func backClick(_ sender: UIButton) {
        CardSegue.transitionManager.transitioning = true
        if self.isRetention {
            self.performSegue(withIdentifier: "home", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "packs", sender: self)
        }
    }
    
    
    // allow swipe left to exit
    /*
    internal func lastClick() {
        if self.subview?.respondsToSelector("lastClick") != true && self.subview?.canPerformSegueWithIdentifier("last") != true {
            CardSegue.transitionManager.transitioning = true
            self.backClick((self.view ~> (UIButton.self ~* 26)).first!)
        }
    }
    */
    
    static var cardTypes: UIStoryboard? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.card == nil {
            if self.isRetention {
                if self.selectedPack != nil {
                    self.card = self.selectedPack!.getUserPack(AppDelegate.getUser()).getRetentionCard()
                }
                else {
                    self.card = AppDelegate.getUser()!.getRetentionCard()
                }
            }
            else {
                if self.pack == nil {
                    print("Pack is nil error")
                }
                self.card = self.pack.getUserPack(AppDelegate.getUser()).getRetryCard()
            }
        }
        if self.isRetention {
            if self.selectedPack != nil {
                self.pack = self.selectedPack!
                let index = self.selectedPack!.getUserPack(AppDelegate.getUser()).getRetentionIndex(self.card!)
                let count = self.selectedPack!.getUserPack(AppDelegate.getUser()).getRetentionCount()
                self.countLabel.text = "\(index+1) of \(count)"
            }
            else {
                self.pack = self.card!.pack!
                let index = AppDelegate.getUser()!.getRetentionIndex(self.card!)
                let count = AppDelegate.getUser()!.getRetentionCount()
                self.countLabel.text = "\(index+1) of \(count)"
            }
        }
        else {
            self.pack = self.card!.pack!
            let index = self.pack.getUserPack(AppDelegate.getUser()).getRetryIndex(self.card!)
            let count = self.pack.getUserPack(AppDelegate.getUser()).getRetryCount()
            self.countLabel.text = "\(index+1) of \(count)"
        }
        self.packTitle.text = self.pack.title
        if self.subview == nil {
            var view = "Default"
            if self.card?.response_type == "mc" {
                view = "Multiple"
            }
            else if self.card?.response_type == "tf" {
                view = "TrueFalse"
            }
            else if self.card?.response_type == "sa" {
                view = "Blank"
            }
            if CardController.cardTypes == nil {
                CardController.cardTypes = UIStoryboard(name: "CardTypes", bundle: nil)
            }
            self.subview = CardController.cardTypes!.instantiateViewController(withIdentifier: view)
        }
        self.subview!.view.translatesAutoresizingMaskIntoConstraints = false
        self.embeddedView.addSubview(self.subview!.view)
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
    }
    
    override func getAnalytics() -> String {
        if self.card != nil {
            let process = self.isRetention ? "BigButton" : "PackSummary"
            let pack = self.pack.title!.matchesForRegexInText("\\s[a-z]|[A-Z]").map {
                return $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}.joined(separator: "").uppercased(with: nil)
            let card = (self.view ~> UITextView.self).first!.text
            let cardShort = card!.substring(to: card!.characters.index(card!.startIndex, offsetBy: min(card!.characters.count, 30)))
            return "\(process)/\(self.pack!.id!)-\(pack)/\(self.card!.id!)-\(cardShort)"
        }
        return super.getAnalytics()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PackResultsController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
            vc.selectedPack = self.selectedPack
        }
        if let vc = segue.destination as? CardController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
            vc.selectedPack = self.selectedPack
            if vc.subview != nil {
                vc.card = self.card
                vc.intermediateResponse = self.intermediateResponse
            }
        }
        if let vc = segue.destination.parent as? CardController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
            vc.selectedPack = self.selectedPack
            if vc.subview != nil {
                vc.card = self.card
                vc.intermediateResponse = self.intermediateResponse
            }
        }
    }
}


