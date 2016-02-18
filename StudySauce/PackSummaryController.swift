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
        doMain(self.viewDidLoad)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.viewDidLoad()
    }
    
    // load the card content, display and available answers
    // TODO: Constrains are intentionally not used in the SQLite database ID columns to allow soft relations to other tables
    //   if the database is ever changed this feature of SQLite has to be transfered or these download functions will have to be refactored.
    private static func getCards(forPack: Pack, _ user: User, _ completionHandler: ([Card], NSError!) -> Void) -> Void {
        var cards = forPack.cards?.allObjects as! [Card]
        let url = AppDelegate.studySauceCom("/packs/download/\(user.id!)?pack=\(forPack.id!)")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if user != AppDelegate.getUser() {
                forPack.isDownloading = false
                return
            }
            if (error != nil) {
                forPack.isDownloading = false
                return completionHandler([], error)
            }
            
            AppDelegate.performContext {
                var ids = [NSNumber]()
                
                // load packs from server
                let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
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
                    
                    // sync responses
                    self.processResponses(user, card["responses"] as! NSArray)
                }
                
                // remove cards that no longer exist
                for p in cards {
                    if ids.indexOf(p.id!) == nil {
                        AppDelegate.deleteObject(p)
                        cards.removeAtIndex(cards.indexOf(p)!)
                    }
                }
                
                if user != AppDelegate.getUser() {
                    forPack.isDownloading = false
                    return
                }
                
                AppDelegate.saveContext()
                completionHandler(cards, nil)
            }
        })
        task.resume()
    }
    
    static internal func processResponses(user: User, _ json: NSArray) {
        for response in json {
            var newResponse = response["id"] as? NSNumber != nil ? AppDelegate.get(Response.self, response["id"] as! NSNumber) : nil
            if newResponse == nil {
                newResponse = AppDelegate.insert(Response.self)
                newResponse!.id = response["id"] as? NSNumber
            }
            let card = AppDelegate.get(Card.self, response["card"] as! NSNumber)
            if card == nil {
                print("Card not found")
            }
            newResponse!.correct = response["correct"] as? NSNumber == 1
            newResponse!.answer = card!.getAllAnswers().filter({$0.id == response["answer"] as? NSNumber}).first
            newResponse!.value = response["value"] as? String
            newResponse!.card = card!
            newResponse!.created = NSDate.parse(response["created"] as? String)
            newResponse!.user = user
        }

        AppDelegate.saveContext()
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
        getJson("/packs/list/\(user.id!)", done: {json in
            AppDelegate.performContext {
                var ids = [NSNumber]()
                for pack in json as! NSArray {
                    var newPack = pack["id"] as? NSNumber != nil ? AppDelegate.get(Pack.self, pack["id"] as! NSNumber) : nil
                    if pack["deleted"] as? Bool == true {
                        continue
                    }
                    if newPack == nil {
                        newPack = AppDelegate.insert(Pack.self)
                    }
                    
                    ids.insert(pack["id"] as! NSNumber, atIndex: 0)
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
                    
                    if let userPacks = pack["users"] as? NSArray where userPacks.count > 0 {
                        for up in userPacks {
                            if up["id"] as? NSNumber == user.id {
                                self.downloadIfNeeded(newPack!, user) {
                                    downloadedHandler(newPack!)
                                }
                            }
                        }
                    }
                }

                // remove packs that no longer exist
                for p in AppDelegate.list(Pack.self) {
                    if ids.indexOf(p.id!) == nil {
                        for up in p.user_packs?.allObjects as! [UserPack] {
                            AppDelegate.deleteObject(up)
                        }
                        AppDelegate.deleteObject(p)
                    }
                }
                
                AppDelegate.saveContext()
                completionHandler()
            }
        })
        
    }

    private func getPacksFromLocalStore() -> Void
    {
        AppDelegate.performContext {
            var packs = [Pack]()
            for p in AppDelegate.list(Pack.self) {
                let userPacks = p.user_packs?.allObjects as? [UserPack] ?? []
                if userPacks.filter({$0.user?.id == AppDelegate.getUser()?.id}).count > 0 {
                    packs.insert(p, atIndex: 0)
                }
            }
            self.packs = packs
            doMain {
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
                        AppDelegate.performContext {
                            p.isDownloading = false
                            if user != AppDelegate.getUser() {
                                return
                            }
                            up.retries = ""
                            up.downloaded = NSDate()
                            AppDelegate.saveContext()
                            done()
                        }
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
        let user = AppDelegate.getUser()!
        PackSummaryController.downloadIfNeeded(self.pack!, user) { () -> Void in
            self.transitionToCard()
        }
    }
    
    private func transitionToCard() {
        let user = AppDelegate.getUser()!
        if self.pack == nil || CardSegue.transitionManager.transitioning {
            return
        }
        doMain {
            if self.pack!.cards!.count  == 0 {
                // something went wrong
                return
            }
            if self.pack!.getUserPack(user).getRetryCard() == nil {
                self.pack!.getUserPack(user).getRetries(true)
            }
            self.performSegueWithIdentifier("card", sender: self)
            self.pack = nil
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
        if self.packs == nil || (!self.packsLoaded && self.packs!.count == 0) {
            return tableView.dequeueReusableCellWithIdentifier("Loading")!
        }
        if self.packs!.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("NoPacks")!
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackSummaryCell
        
        let object = self.packs![indexPath.row]
        cell.updateTableView = {
            // list all packs with the same icon
            let indexes = self.packs!.filter({$0.logo != nil}).map({NSIndexPath(forRow: self.packs!.indexOf($0)!, inSection: 0)})
            tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        cell.configure(object)
        return cell
    }
    
}

