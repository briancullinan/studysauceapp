//
//  AppDelegateTheme.swift
//  StudySauce
//
//  Created by Stephen Houghton on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
    func setupTheme() {
        
        HomeController > UILabel
        
        UILabel.appearance().setFontFamily("Verdana-Bold")
        UITextView.appearance().setFontFamily("Verdana-Bold")
        UIButton.appearance().setFontFamily("Verdana-Bold")
        UITextField.appearance().setFontFamily("Verdana-Bold")
        UILabel.appearance().setFontColor(UIColor(hex: 0x424242))
        
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
        
    }
}