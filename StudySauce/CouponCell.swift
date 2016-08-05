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

public class CouponCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UIButton!
    
    weak var json: NSDictionary? = nil
    
    func downloadLogo(url: String) {
        self.logoImage.hidden = true
        File.save(url) {(f :File) in
            let fileName = f.filename!
            let fileManager = NSFileManager.defaultManager()
            if let data = fileManager.contentsAtPath(fileName) {
                doMain {
                    self.logoImage.image = UIImage(data: data)
                    self.logoImage.hidden = false
                    
                    if let vc = AppDelegate.visibleViewController() as? PackSummaryController {
                        (vc.view ~> PackSummaryCell.self).each {
                            if $0.pack!.logo == self.json!["logo"] as? String ?? "" && $0.logoImage.hidden {
                                $0.logoImage.image = self.logoImage.image
                                $0.logoImage.hidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    internal func configure(json: NSDictionary) {
        self.json = json
        let title = json["description"] as? String ?? ""
        var url = json["logo"] as? String ?? ""
        if url.isEmpty {
            url = AppDelegate.studySauceCom("/bundles/studysauce/images/upload_image.png").absoluteString
        }
        AppDelegate.performContext {
            if let f = AppDelegate.list(File.self).filter({$0.url! == url}).first where f.filename != nil {
                let fileName = f.filename!
                let fileManager = NSFileManager.defaultManager()
                if let data = fileManager.contentsAtPath(fileName) {
                    doMain {
                        self.logoImage.image = UIImage(data: data)
                        self.logoImage.hidden = false
                    }
                }
                else {
                    self.downloadLogo(url)
                }
            }
            else {
                self.downloadLogo(url)
            }
        }
        let count = json["cardCount"] as? Int ?? 0
        let s = count == 1 ? " card" : " cards"
        let option = json["options"]?.allKeys[0] as? String ?? ""
        let props = json["options"] as! NSDictionary
        let price = (props[option] as! NSDictionary)["price"] ?? ""
        let dbl = Double("\(price!)")
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        self.countLabel.setTitle((dbl ?? 0.0).isZero ? "Free" : formatter.stringFromNumber(dbl!), forState: UIControlState.Normal)
        self.titleLabel.text = title
    }
}