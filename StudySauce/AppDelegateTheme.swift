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
        
        let saucyGray = UIColor(hex: 0xE9E9E9)
        let saucyFontColor = UIColor(hex: 0x424242)
        
        $(UILabel.self).setFontColor(saucyFontColor)
        $(UIButton.self + UILabel.self).setFontColor(saucyGray)
        $(UIButton.self > UILabel.self).setFontName("Courier")
        
        //UILabel.appearance().setFontName("Verdana-Bold")
        //UITextView.appearance().setFontFamily("Verdana-Bold")
        //UIButton.appearance().setFontFamily("Verdana-Bold")
        //UITextField.appearance().setFontFamily("Verdana-Bold")
        //UILabel.appearance().setFontColor()
        
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
        
    }
}