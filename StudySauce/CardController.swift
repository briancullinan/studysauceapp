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
    internal var intermediateResponse: Response? = nil
    internal var pack: Pack!
    internal var card: Card? = nil
    internal var subview: UIViewController? = nil {
        didSet {
            self.addChildViewController(self.subview!)
            self.subview!.didMoveToParentViewController(self)
        }
    }
    internal var isRetention = false
    internal var selectedPack: Pack? = nil

    @IBAction func backClick(sender: UIButton) {
        if self.isRetention {
            self.performSegueWithIdentifier("home", sender: self)
        }
        else {
            self.performSegueWithIdentifier("packs", sender: self)
        }
    }
    
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
                self.card = self.pack.getUserPack(AppDelegate.getUser()).getRetryCard()
            }
        }
        if self.isRetention {
            if self.selectedPack != nil {
                self.pack = self.selectedPack
                let index = self.selectedPack!.getUserPack(AppDelegate.getUser()).getRetentionIndex(self.card!)
                let count = self.selectedPack!.getUserPack(AppDelegate.getUser()).getRetentionCount()
                self.countLabel.text = "\(index+1) of \(count)"
            }
            else {
                self.pack = self.card!.pack
                let index = AppDelegate.getUser()!.getRetentionIndex(self.card!)
                let count = AppDelegate.getUser()!.getRetentionCount()
                self.countLabel.text = "\(index+1) of \(count)"
            }
        }
        else {
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
            self.subview = self.storyboard!.instantiateViewControllerWithIdentifier(view)
        }
        self.subview!.view.translatesAutoresizingMaskIntoConstraints = false
        self.embeddedView.addSubview(self.subview!.view)
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    override func getAnalytics() -> String {
        if self.card != nil {
            let process = self.isRetention ? "BigButton" : "PackSummary"
            let pack = self.pack.title!.matchesForRegexInText("\\s[a-z]|[A-Z]").map {
                return $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())}.joinWithSeparator("").uppercaseStringWithLocale(nil)
            let card = (self.view ~> UITextView.self).first!.text
            let cardShort = card!.substringToIndex(card!.startIndex.advancedBy(min(card!.characters.count, 30)))
            return "\(process)/\(self.pack!.id!)-\(pack)/\(self.card!.id!)-\(cardShort)"
        }
        return super.getAnalytics()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
            vc.selectedPack = self.selectedPack
        }
        if let vc = segue.destinationViewController as? CardController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
            vc.selectedPack = self.selectedPack
            if vc.subview != nil {
                vc.card = self.card
                vc.intermediateResponse = self.intermediateResponse
            }
        }
        if let vc = segue.destinationViewController.parentViewController as? CardController {
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


