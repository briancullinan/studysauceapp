
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


open class PackRetentionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    weak var pack: Pack? = nil
    
    internal func configure(_ pack: Pack) {
        self.pack = pack
        let title = pack.title
        var creator = pack.creator
        if creator == nil || creator == "" {
            creator = " "
        }
        var modified = pack.modified
        if modified == nil {
            modified = pack.created
        }
        let up = pack.getUserPack(AppDelegate.getUser())
        let count = up.getRetentionCount()
        self.countLabel.text = "\(count)";
        self.titleLabel.text = title
        // TODO: check number of responses in pack
        if up.downloaded == nil || up.created == nil || up.created!.addingTimeInterval(60*2) > Date() || (
            (up.retention as? NSDictionary)?.filter({($0.value as? NSArray)?[0] as? Int > 0}).count == 0 &&
            AppDelegate.getPredicate(Response.self, NSPredicate(format: "user=%@ AND card.pack=%@", AppDelegate.getUser()!, pack)).count == 0) {
            newLabel.isHidden = false
            newLabel.text = "New "
        }
        else {
            newLabel.isHidden = true
            newLabel.text = ""
        }
    }
}
