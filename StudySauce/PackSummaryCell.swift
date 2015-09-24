//
//  PackSummaryCell.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/22/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class PackSummaryCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    
    weak var pack: Pack!
    
    func getData(completionHandler: ([Card], NSError!) -> Void) -> Void {
        var packs = [Card]()
        if let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Card")
            do {
                for p in try moc.executeFetchRequest(fetchRequest) as! [Card] {
                    packs.insert(p, atIndex: 0)
                }
                completionHandler(packs, nil)
            }
            catch let error as NSError {
                NSLog("Failed to retrieve record: \(error.localizedDescription)")
            }
            let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/cards?pack=\(self.pack.id)")!
            let ses = NSURLSession.sharedSession()
            let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if (error != nil) {
                    return completionHandler([], error)
                }
                
                do {
                    // TODO: remove packs that no longer exist
                    for p in packs {
                        moc.deleteObject(p)
                        packs.removeAtIndex(packs.indexOf(p)!)
                    }
                    
                    // load packs from server
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    for pack in json as! NSArray {
                        var newPack: Card?
                        for p in packs {
                            if p.id == pack["id"] as? NSNumber {
                                newPack = p
                            }
                        }
                        if newPack == nil {
                            newPack = NSEntityDescription.insertNewObjectForEntityForName("Pack", inManagedObjectContext: moc) as? Card
                        }
                        
                        newPack!.content = pack["content"] as? String
                        newPack!.id = pack["id"] as? NSNumber
                        newPack!.pack = self.pack
                        newPack!.created = pack["created"] as? NSDate
                        packs.insert(newPack!, atIndex: 0)
                        try moc.save()
                    }
                    completionHandler(packs, nil)
                }
                catch let error as NSError {
                    completionHandler([], error)
                }
            })
            task.resume()
        }
    }
    
    public func configure(logo: UIImage?, title: String?, creator: String?) {
        logoImage.image = logo
        titleLabel.text = title
        creatorLabel.text = creator
    }
    
    
}