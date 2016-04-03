//
//  MasterViewController.swift
//  StudySauce
//
//  Created by admin on 9/12/15.
//  Copyright (c) 2015 The Study Institute. All rights reserved.
//

import UIKit
import CoreData

class PackSummaryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var packs: [Pack]? = nil
    var pack: Pack? = nil
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func returnToPacks(segue: UIStoryboardSegue) {

    }
    
    override func viewDidAppear(animated: Bool) {
        self.pack = nil
        self.viewDidLoad()
    }
    
    // load the card content, display and available answers
    // TODO: Constrains are intentionally not used in the SQLite database ID columns to allow soft relations to other tables
    //   if the database is ever changed this feature of SQLite has to be transfered or these download functions will have to be refactored.
    private static func getCards(forPack: Pack, _ user: User, _ completionHandler: ([Card], NSError!) -> Void) -> Void {
        var cards = AppDelegate.getPredicate(Card.self, NSPredicate(format: "pack==%@", forPack))
        
        getJson("/packs/download/\(user.id!)", ["pack" : forPack.id!]) {(json: AnyObject) in
            AppDelegate.performContext {
                if(user != AppDelegate.getUser()) {
                    return
                }
                var ids = [NSNumber]()
                
                for card in json as! NSArray {
                    var newCard = card["id"] as? NSNumber != nil ? AppDelegate.get(Card.self, card["id"] as! NSNumber) : nil
                    if newCard == nil {
                        newCard = AppDelegate.insert(Card.self)
                        cards.insert(newCard!, atIndex: 0)
                    }
                    
                    ids.insert(card["id"] as! NSNumber, atIndex: 0)
                    newCard!.id = card["id"] as? NSNumber
                    newCard!.content = card["content"] as? String
                    newCard!.response = card["response"] as? String
                    newCard!.response_type = card["response_type"] as? String
                    newCard!.pack = forPack
                    newCard!.created = NSDate.parse(card["created"] as? String)
                    newCard!.modified = NSDate.parse(card["modified"] as? String)
                    AppDelegate.saveContext()
                    
                    self.processAnswers(newCard!, json: card["answers"] as! NSArray)
                }
                
                // remove cards that no longer exist
                for p in cards {
                    if ids.indexOf(p.id!) == nil {
                        AppDelegate.deleteObject(p)
                        cards.removeAtIndex(cards.indexOf(p)!)
                    }
                }
                
                AppDelegate.saveContext()
                completionHandler(cards, nil)
            }
        }
        
    }
    
    static private func processAnswers(card: Card, json: NSArray) {
        // create anwers
        var answers = card.getAllAnswers()
        var answerIds = [NSNumber]()
        for answer in json {
            var newAnswer: Answer?
            for a in answers {
                if a.id == answer["id"] as? NSNumber {
                    newAnswer = a
                }
            }
            if newAnswer == nil {
                newAnswer = AppDelegate.insert(Answer.self)
                answers.insert(newAnswer!, atIndex: 0)
            }
            
            answerIds.insert(answer["id"] as! NSNumber, atIndex: 0)
            newAnswer!.id = answer["id"] as? NSNumber
            newAnswer!.content = answer["content"] as? String
            newAnswer!.value = answer["value"] as? String
            newAnswer!.card = card
            newAnswer!.correct = answer["correct"] as? NSNumber
            newAnswer!.created = NSDate.parse(answer["created"] as? String)
            newAnswer!.modified = NSDate.parse(answer["modified"] as? String)
        }
        AppDelegate.saveContext()
        
        // remove answers that no longer exist
        for a in answers {
            if answerIds.indexOf(a.id!) == nil {
                AppDelegate.deleteObject(a)
                answers.removeAtIndex(answers.indexOf(a)!)
            }
        }

        AppDelegate.saveContext()
    }
    
    internal static func getPacks(completionHandler: () -> Void, downloadedHandler: (Pack) -> Void = {(p: Pack) -> Void in return}) -> Void {
        let user = AppDelegate.getUser()!
        getJson("/packs/list/\(user.id!)") {json in
            AppDelegate.performContext {
                if AppDelegate.getUser() != user {
                    return
                }
                var ids = [NSNumber]()
                for pack in json as! NSArray {
                    var newPack = pack["id"] as? NSNumber != nil ? AppDelegate.get(Pack.self, pack["id"] as! NSNumber) : nil
                    if pack["deleted"] as? Bool == true {
                        continue
                    }
                    var isNew = false
                    if newPack == nil {
                        newPack = AppDelegate.insert(Pack.self)
                        isNew = true
                    }
                    ids.insert(pack["id"] as! NSNumber, atIndex: 0)
                    if isNew || NSDate.parse(pack["modified"] as? String) == nil || newPack!.modified == nil || NSDate.parse(pack["modified"] as? String)! > newPack!.modified! {
                        newPack!.id = pack["id"] as? NSNumber
                        newPack!.title = pack["title"] as? String
                        newPack!.creator = pack["creator"] as? String
                        newPack!.logo = pack["logo"] as? String
                        newPack!.created = NSDate.parse(pack["created"] as? String)
                        newPack!.modified = NSDate.parse(pack["modified"] as? String)
                        newPack!.count = pack["count"] as? NSNumber
                        let properties = pack["properties"] as? NSDictionary
                        for p in properties?.allKeys ?? [] {
                            newPack!.setProperty("\(p)", properties?.valueForKey("\(p)"))
                        }
                        AppDelegate.saveContext()
                    }
                    
                    if let userPacks = pack["users"] as? NSArray where userPacks.count > 0 {
                        var hasPack = false
                        for up in userPacks {
                            if up["id"] as? NSNumber == user.id {
                                hasPack = true
                                let userPack = newPack!.getUserPack(user)
                                userPack.created = NSDate.parse(up["created"] as? String)
                                self.downloadIfNeeded(newPack!, user) {
                                    downloadedHandler(newPack!)
                                }
                            }
                        }
                        if !hasPack {
                            AppDelegate.deleteObject(newPack!.getUserPack(user))
                        }
                        AppDelegate.saveContext()
                    }
                }

                // remove packs that no longer exist
                for p in AppDelegate.list(Pack.self) {
                    if ids.indexOf(p.id!) == nil {
                        for up in p.user_packs?.allObjects as! [UserPack] {
                            AppDelegate.deleteObject(up)
                        }
                        for c in p.cards?.allObjects as! [Card] {
                            AppDelegate.deleteObject(c)
                        }
                        AppDelegate.deleteObject(p)
                    }
                }
                
                AppDelegate.saveContext()
                completionHandler()
            }
        }
    }

    private func getPacksFromLocalStore() -> Void
    {
        AppDelegate.performContext {
            let packs = AppDelegate.getPredicate(Pack.self, NSPredicate(format: "ANY user_packs.user==%@", AppDelegate.getUser()!))
            doMain {
                self.packs = packs
                self.tableView.reloadData()
            }
        }
    }
    
    var packsLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPacksFromLocalStore()
        // refresh data from server
        PackSummaryController.getPacks({
            self.packsLoaded = true
            self.getPacksFromLocalStore()
            }, downloadedHandler: { (p: Pack) -> Void in
                if p == self.pack {
                    self.transitionToCard()
                }
                else {
                    self.packsLoaded = true
                    self.getPacksFromLocalStore()
                }
        })
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardController {
            vc.pack = self.pack
        }
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.pack = self.pack
        }
    }
    
    internal static func downloadIfNeeded(p: Pack, _ user: User, _ done: () -> Void) {
        // only downloaded the pack if updates are needed
        if p.isDownloading {
            return
        }
        AppDelegate.performContext {
            if user != AppDelegate.getUser() {
                return
            }
            let up = p.getUserPack(user)
            if p.cards!.count == 0 || up.downloaded == nil
                || (p.modified != nil && p.modified! > up.downloaded!) {
                    
                    p.isDownloading = true
                    
                    PackSummaryController.getCards(p, user) {_,_ in
                        // TODO: update downloading status in table row!
                        p.isDownloading = false
                        up.retries = ""
                        up.downloaded = NSDate()
                        AppDelegate.saveContext()
                        if user != AppDelegate.getUser() {
                            return
                        }
                        done()
                    }
            }
            else {
                done()
            }
        }
    }
    
    // MARK: - Table View
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.packs == nil || self.packs!.count == 0 {
            return
        }
        self.pack = self.packs![indexPath.row]
        self.transitionToCard()
    }
    
    private func transitionToCard() {
        if self.pack == nil || CardSegue.transitionManager.transitioning ||
            !(AppDelegate.visibleViewController() is PackSummaryController) {
            return
        }
        let user = AppDelegate.getUser()!
        PackSummaryController.downloadIfNeeded(self.pack!, user) { () -> Void in
            AppDelegate.performContext {
                let user = AppDelegate.getUser()!
                if self.pack!.cards!.count  == 0 {
                    // something went wrong
                    return
                }
                if self.pack!.getUserPack(user).getRetryCard() == nil {
                    self.pack!.getUserPack(user).getRetries(true)
                }
                print("Starting \(self.pack!.cards!.count) cards")
                doMain {
                    if self.pack == nil || CardSegue.transitionManager.transitioning ||
                        !(AppDelegate.visibleViewController() is PackSummaryController) {
                        return
                    }
                    self.performSegueWithIdentifier("card", sender: self)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight * 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.packs == nil || self.packs!.count == 0 {
            return 1
        }
        return self.packs!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.packsLoaded && self.packs!.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("NoPacks")!
        }
        else if self.packs == nil || self.packs!.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("Loading")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackSummaryCell
        
        let object = self.packs![indexPath.row]
        cell.configure(object)
        return cell
    }
    
}

