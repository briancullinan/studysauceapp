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
    
    @IBAction func returnToPacks(_ segue: UIStoryboardSegue) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pack = nil
        self.viewDidLoad()
    }
    
    // load the card content, display and available answers
    // TODO: Constrains are intentionally not used in the SQLite database ID columns to allow soft relations to other tables
    //   if the database is ever changed this feature of SQLite has to be transfered or these download functions will have to be refactored.
    fileprivate static func getCards(_ forPack: Pack, _ user: User, _ completionHandler: @escaping ([Card], NSError?) -> Void) -> Void {
        var cards = AppDelegate.getPredicate(Card.self, NSPredicate(format: "pack==%@", forPack))
        
        getJson("/packs/download/\(user.id!)", ["pack" : forPack.id!]) {(json: AnyObject) in
            AppDelegate.performContext {
                if(user != AppDelegate.getUser()) {
                    return
                }
                var ids = [NSNumber]()
                
                for card: [String:Any] in json as! [[String:Any]] {
                    var newCard = card["id"] as? NSNumber != nil ? cards.filter({$0.id == (card["id"] as! NSNumber)}).first : nil
                    if newCard == nil {
                        newCard = AppDelegate.insert(Card.self)
                        newCard!.pack = forPack
                        cards.insert(newCard!, at: 0)
                    }
                    
                    ids.insert(card["id"] as! NSNumber, at: 0)
                    newCard!.id = card["id"] as? NSNumber
                    newCard!.content = card["content"] as? String
                    newCard!.response = card["response"] as? String
                    newCard!.response_type = card["response_type"] as? String
                    newCard!.created = Date.parse(card["created"] as? String)
                    newCard!.modified = Date.parse(card["modified"] as? String)
                    AppDelegate.saveContext()
                    
                    self.processAnswers(newCard!, json: card["answers"] as! [[String:Any]])
                }
                
                // remove cards that no longer exist
                for p in cards {
                    if ids.index(of: p.id!) == nil {
                        AppDelegate.deleteObject(p)
                        cards.remove(at: cards.index(of: p)!)
                    }
                }
                
                AppDelegate.saveContext()
                completionHandler(cards, nil)
            }
        }
        
    }
    
    static fileprivate func processAnswers(_ card: Card, json: [[String:Any]]) {
        // create anwers
        var answers = card.getAllAnswers()
        var answerIds = [NSNumber]()
        for answer: [String:Any] in json {
            var newAnswer: Answer?
            for a in answers {
                if a.id == answer["id"] as? NSNumber {
                    newAnswer = a
                }
            }
            if newAnswer == nil {
                newAnswer = AppDelegate.insert(Answer.self)
                answers.insert(newAnswer!, at: 0)
            }
            
            answerIds.insert(answer["id"] as! NSNumber, at: 0)
            newAnswer!.id = answer["id"] as? NSNumber
            newAnswer!.content = answer["content"] as? String
            newAnswer!.value = answer["value"] as? String
            newAnswer!.card = card
            newAnswer!.correct = answer["correct"] as? NSNumber
            newAnswer!.created = Date.parse(answer["created"] as? String)
            newAnswer!.modified = Date.parse(answer["modified"] as? String)
        }
        AppDelegate.saveContext()
        
        // remove answers that no longer exist
        for a in answers {
            if answerIds.index(of: a.id!) == nil {
                AppDelegate.deleteObject(a)
                answers.remove(at: answers.index(of: a)!)
            }
        }

        AppDelegate.saveContext()
    }
    
    internal static func getPacks(_ completionHandler: @escaping () -> Void, downloadedHandler: @escaping (Pack) -> Void = {(p: Pack) -> Void in return}) -> Void {
        let user = AppDelegate.getUser()!
        getJson("/packs/list/\(user.id!)") {json in
            AppDelegate.performContext {
                if AppDelegate.getUser() != user {
                    return
                }
                var ids = [NSNumber]()
                for pack in json as! [[String:Any]] {
                    var newPack = pack["id"] as? NSNumber != nil ? AppDelegate.get(Pack.self, pack["id"] as! NSNumber) : nil
                    if pack["deleted"] as? Bool == true {
                        continue
                    }
                    var isNew = false
                    if newPack == nil {
                        newPack = AppDelegate.insert(Pack.self)
                        isNew = true
                    }
                    ids.insert(pack["id"] as! NSNumber, at: 0)
                    if isNew || Date.parse(pack["modified"] as? String) == nil || newPack!.modified == nil || Date.parse(pack["modified"] as? String)! > newPack!.modified! {
                        newPack!.id = pack["id"] as? NSNumber
                        newPack!.title = pack["title"] as? String
                        newPack!.creator = pack["creator"] as? String
                        newPack!.logo = pack["logo"] as? String
                        newPack!.created = Date.parse(pack["created"] as? String)
                        newPack!.modified = Date.parse(pack["modified"] as? String)
                        newPack!.count = pack["count"] as? NSNumber
                        if let properties = pack["properties"] as? [String:Any] {
                            for p in properties.keys {
                                newPack!.setProperty("\(p)", "\(properties["\(p)"])" as AnyObject)
                            }
                        }
                        AppDelegate.saveContext()
                    }
                    
                    if let userPacks = pack["users"] as? [[String:Any]] , userPacks.count > 0 {
                        var hasPack = false
                        for up in userPacks {
                            if up["id"] as? NSNumber == user.id {
                                hasPack = true
                                let userPack = newPack!.getUserPack(user)
                                userPack.created = Date.parse(up["created"] as? String)
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
                    if ids.index(of: p.id!) == nil {
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

    fileprivate func getPacksFromLocalStore() -> Void
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CardController {
            vc.pack = self.pack
        }
        if let vc = segue.destination as? PackResultsController {
            vc.pack = self.pack
        }
    }
    
    internal static func downloadIfNeeded(_ p: Pack, _ user: User, _ done: @escaping () -> Void) {
        // only downloaded the pack if updates are needed
        if p.isDownloading {
            return
        }
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
                up.downloaded = Date()
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

    // MARK: - Table View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            self.transitionToStore()
            return
        }
        if self.packs == nil || self.packs!.count == 0 {
            return
        }
        self.pack = self.packs![(indexPath as NSIndexPath).row - 1]
        self.transitionToCard()
    }
    
    fileprivate func transitionToStore() {
        if CardSegue.transitionManager.transitioning ||
            !(AppDelegate.visibleViewController() is PackSummaryController) {
            return
        }
        self.performSegue(withIdentifier: "store", sender: self)
    }
    
    fileprivate func transitionToCard() {
        if self.pack == nil || CardSegue.transitionManager.transitioning ||
            !(AppDelegate.visibleViewController() is PackSummaryController) {
            return
        }
        let user = AppDelegate.getUser()!
        AppDelegate.performContext {
            PackSummaryController.downloadIfNeeded(self.pack!, user) { () -> Void in
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
                    self.performSegue(withIdentifier: "card", sender: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight * 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.packs == nil || self.packs!.count == 0 {
            return 2
        }
        return self.packs!.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "Store")!
        }
        if self.packsLoaded && self.packs?.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "NoPacks")!
        }
        else if self.packs == nil || self.packs!.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "Loading")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PackSummaryCell
        
        let object = self.packs![(indexPath as NSIndexPath).row - 1]
        cell.configure(object)
        return cell
    }
    
}

