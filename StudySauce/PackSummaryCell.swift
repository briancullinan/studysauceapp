//
//  PackSummaryCell.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/22/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

import UIKit

public class PackSummaryCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBAction func downloadClick(sender: UIButton, forEvent event: UIEvent) {
        // TODO: check the database if the pack is downloaded and start the background sync process
        
    }
    
    public func configure(logo: UIImage?, title: String?, creator: String?) {
        logoImage.image = logo
        titleLabel.text = title
        creatorLabel.text = creator
        
    }
    
    
}