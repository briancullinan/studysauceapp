//
//  ContentViewController.swift
//  StudySauce
//
//  Created by Stephen Houghton on 12/17/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

class TutorialContentViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationlabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex: Int!
    var titleText: String!
    var explanationText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.imageView.image = UIImage(named: self.imageFile)
        self.titleLabel.text = self.titleText
        self.explanationlabel.text = self.explanationText

        }
        
    }