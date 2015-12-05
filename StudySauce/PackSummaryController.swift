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
    
    var packs = [Pack]()
    var pack: Pack? = nil
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func returnToPacks(segue: UIStoryboardSegue) {
        
    }

    // load the card content, display and available answers
    // TODO: Constrains are intentionally not used in the SQLite database ID columns to allow soft relations to other tables
    //   if the database is ever changed this feature of SQLite has to be transfered or these download functions will have to be refactored.
    internal static func getCards(forPack: Pack, completionHandler: ([Card], NSError!) -> Void) -> Void {
        var cards = forPack.cards?.allObjects as! [Card]
        if let moc = AppDelegate.getContext() {
            let url = AppDelegate.studySauceCom("/packs/download?pack=\(forPack.id!)")
            let ses = NSURLSession.sharedSession()
            let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if (error != nil) {
                    return completionHandler([], error)
                }
                
                do {
                    var ids = [NSNumber]()
                    
                    // load packs from server
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    for card in json as! NSArray {
                        var newCard: Card?
                        for p in cards {
                            if p.id == card["id"] as? NSNumber {
                                newCard = p
                            }
                        }
                        if newCard == nil {
                            newCard = moc.insert(Card.self)
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
                        
                        self.processAnswers(newCard!, json: card["answers"] as! NSArray)
                        
                        // sync responses
                        self.processResponses(newCard!, json: card["responses"] as! NSArray)
                    }
                    
                    // remove cards that no longer exist
                    for p in cards {
                        if ids.indexOf(p.id!) == nil {
                            moc.deleteObject(p)
                            cards.removeAtIndex(cards.indexOf(p)!)
                        }
                    }
                    
                    AppDelegate.saveContext()
                    completionHandler(cards, nil)
                }
                catch let error as NSError {
                    completionHandler([], error)
                }
            })
            task.resume()
        }
    }
    
    static private func processResponses(card: Card, json: NSArray) {
        var responses = card.getAllResponses()
        for response in json {
            var newResponse: Response?
            for r in responses {
                if r.id == response["id"] as? NSNumber {
                    newResponse = r
                }
            }
            if newResponse == nil {
                newResponse = AppDelegate.getContext()!.insert(Response.self)
                responses.insert(newResponse!, atIndex: 0)
                newResponse!.id = response["id"] as? NSNumber
            }
            
            newResponse!.correct = response["correct"] as? NSNumber == 1
            newResponse!.answer = card.getAllAnswers().filter({$0.id == response["answer"] as? NSNumber}).first
            newResponse!.value = response["value"] as? String
            newResponse!.card = card
            newResponse!.created = NSDate.parse(response["created"] as? String)
            newResponse!.user = AppDelegate.getUser()
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
                newAnswer = AppDelegate.getContext()!.insert(Answer.self)
                answers.insert(newAnswer!, atIndex: 0)
            }
            
            answerIds.insert(answer["id"] as! NSNumber, atIndex: 0)
            newAnswer!.id = answer["id"] as? NSNumber
            //newAnswer!.content = answer["content"] as? String
            //newAnswer!.response = answer["response"] as? String
            newAnswer!.value = answer["value"] as? String
            newAnswer!.card = card
            newAnswer!.correct = answer["correct"] as? NSNumber
            newAnswer!.created = NSDate.parse(answer["created"] as? String)
            newAnswer!.modified = NSDate.parse(answer["modified"] as? String)
        }
        
        // remove answers that no longer exist
        for a in answers {
            if answerIds.indexOf(a.id!) == nil {
                AppDelegate.getContext()!.deleteObject(a)
                answers.removeAtIndex(answers.indexOf(a)!)
            }
        }

    }
    
    internal static func getPacks(completionHandler: () -> Void, downloadedHandler: (Pack) -> Void = {(p: Pack) -> Void in return}) -> Void {
        getJson("/packs/list", done: {json in
            if let moc = AppDelegate.getContext() {
                var ids = [NSNumber]()
                for pack in json as! NSArray {
                    var newPack: Pack?
                    for p in moc.list(Pack.self) {
                        if p.id == pack["id"] as? NSNumber {
                            newPack = p
                        }
                    }
                    if newPack == nil {
                        newPack = moc.insert(Pack.self)
                    }
                    
                    ids.insert(pack["id"] as! NSNumber, atIndex: 0)
                    newPack!.id = pack["id"] as? NSNumber
                    newPack!.title = pack["title"] as? String
                    newPack!.creator = pack["creator"] as? String
                    newPack!.logo = pack["logo"] as? String
                    newPack!.created = NSDate.parse(pack["created"] as? String)
                    newPack!.modified = NSDate.parse(pack["modified"] as? String)
                    newPack!.count = pack["count"] as? NSNumber
                    if pack["downloaded"] as? NSNumber == 1 {
                        self.downloadIfNeeded(newPack!, done: {
                            downloadedHandler(newPack!)
                        })
                    }
                    if let userPacks = pack["user_packs"] as? NSArray where userPacks.count > 0 {
                        self.downloadIfNeeded(newPack!, done: {
                            let cards = newPack!.cards!.allObjects as! [Card]
                            for p in userPacks {
                                let card = cards.filter({$0.id == p["card"] as? NSNumber}).first
                                self.processResponses(card!, json: p["responses"] as! NSArray)
                            }
                            downloadedHandler(newPack!)
                        })
                    }
                }
                
                // remove packs that no longer exist
                for p in moc.list(Pack.self) {
                    if ids.indexOf(p.id!) == nil {
                        moc.deleteObject(p)
                        moc.deleteObject(p.getUserPack(AppDelegate.getUser()))
                    }
                }
                
                AppDelegate.saveContext()
                completionHandler()
            }
        })
        
    }

    private func getPacksFromLocalStore() -> [Pack]
    {
        var packs = [Pack]()
        if let moc = AppDelegate.getContext() {
            let fetchRequest = NSFetchRequest(entityName: "Pack")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            do {
                for p in try moc.executeFetchRequest(fetchRequest) as! [Pack] {
                    packs.insert(p, atIndex: 0)
                }
            }
            catch let error as NSError {
                NSLog("Failed to retrieve record: \(error.localizedDescription)")
            }
        }
        return packs
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundView = nil
        
        // Load packs from database
        self.packs = getPacksFromLocalStore()
        
        // Make the cell self size
        self.tableView.estimatedRowHeight = 66.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.layoutIfNeeded()
        
        // refresh data from server
        PackSummaryController.getPacks({ () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.packs = self.getPacksFromLocalStore()
                self.tableView.reloadData()
            })
            }, downloadedHandler: {(newPack: Pack) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                // calls every time to check if this pack was clicked on while downloaded
                //if self.pack != nil && self.pack! == newPack {
                //    self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: self.packs.indexOf(self.pack!)!, inSection: 0))
                //}
            })
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
    
    internal static func downloadIfNeeded(p: Pack, done: () -> Void) {
        // only downloaded the pack if updates are needed
        if p.isDownloading {
            return
        }
        let up = p.getUserPack(AppDelegate.getUser())
        if p.cards!.count == 0 || up.downloaded == nil
            || (p.modified != nil && p.modified! > up.downloaded!) {
                p.isDownloading = true
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                    PackSummaryController.getCards(p, completionHandler: {_,_ in
                        // TODO: update downloading status in table row!
                        up.downloaded = NSDate()
                        AppDelegate.saveContext()
                        p.isDownloading = false
                        done()
                    })
                })
        }
        else {
            done()
        }
    }
    
    // MARK: - Table View
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pack = self.packs[indexPath.row]
        PackSummaryController.downloadIfNeeded(self.pack!) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if self.pack!.cards!.count  == 0 {
                    // something went wrong
                    return
                }
                if self.pack!.getUserPack(AppDelegate.getUser()).getRetryCard() == nil {
                    self.pack!.getUserPack(AppDelegate.getUser()).getRetries(true)
                }
                self.performSegueWithIdentifier("card", sender: self)
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackSummaryCell
        
        let object = self.packs[indexPath.row]
        cell.updateTableView = {
            // list all packs with the same icon
            let indexes = self.packs.filter({$0.logo != nil}).map({NSIndexPath(forRow: self.packs.indexOf($0)!, inSection: 0)})
            tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        cell.configure(object)
        return cell
    }
    
}

