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
        
        /*
        Key:
        |> Direct descendent
        |+ Sibling of last element
        |^ Use the view to match properties
        Override Tag with string for className matching instead of stupid number
        Automatically psuedo-attributes like :first-child :last-child
        [] list of TQueryable matches sets of rules
        */
        
        let saucyGray = UIColor(0xE9E9E9)
        let saucyFontColor = UIColor(0x424242)
        
        // set up font names
        //$(UILabel.self).setFontName("Avenir-Medium")
        $(UIButton.self).setFontName("Avenir-Medium")
        
        // set up text colors
        $([UILabel.self,
           UITextView.self,
           UITextField.self], {
            // TODO: chaining would be nicer syntax here
            $0.setFontColor(saucyFontColor)
            $0.setFontName("Avenir-Medium")
            $0.setFontSize(15)
        })
        // nueral background has a tag of 23 and any sibling or sibling child label should be light color
        $(UIImageView.self |^ { $0.tag == 23 } |+ UILabel.self).setFontColor(saucyGray)
        $(UIImageView.self |^ { $0.tag == 23 } |+ UIView.self |> UILabel.self).setFontColor(saucyGray)
        $(HomeController.self |> UITableView.self |+ UILabel.self).setFontColor(saucyFontColor)
        $(HomeController.self |> UITableView.self |> UILabel.self).setFontColor(saucyFontColor)

        // This is the normal way to change appearance on a single type
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
    }
}