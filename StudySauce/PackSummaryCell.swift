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
        
    internal func configure(object: Pack) {
        self.pack = object
        let title = object.title
        let creator = object.creator
        if let url = object.logo where !url.isEmpty {
            let logo = UIImage(data: NSData(contentsOfURL: NSURL(string:url)!)!)!
            logoImage.image = logo
        }
        else {
            logoImage.image = nil
        }

        titleLabel.text = title
        creatorLabel.text = creator
        
    }
    
    
}