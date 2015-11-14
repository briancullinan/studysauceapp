//
//  AppDelegateTheme.swift
//  StudySauce
//
//  Created by Stephen Houghton on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

struct saucyTheme {
    static let lightColor = UIColor(0xE9E9E9)
    static let fontColor = UIColor(0x424242)
    
    static let buttonFont = "Avenir-Medium"
    
    static let textFont = "Avenir-Medium"
    static let textSize = 17.0
    
    static let headingFont = "Avenir-Heavy"
    static let headingSize = 20.0
    static let subheadingFont = "Avenir-Heavy"
    static let subheadingSize = 17.0
}

extension AppDelegate {
    func setupTheme() {
        
        /*
        Key:
        |> Direct descendent
        |+ Sibling of last element
        |^ Use the view to match properties
        |& psuedo-class matching like :first-child :last-child
        |@ Use device properties to determine if setting should apply
        Override Tag with string for className matching instead of stupid number
        [] list of TQueryable matches sets of rules
        */
        
        // set up font names
        $(UIButton.self, {
            $0.setFontName(saucyTheme.buttonFont)
        })
        
        // set up text colors
        $([UILabel.self,
           UITextView.self,
           UITextField.self], {
            // TODO: chaining would be nicer syntax here
            $0.setFontColor(saucyTheme.fontColor)
            $0.setFontName(saucyTheme.textFont)
            $0.setFontSize(CGFloat(saucyTheme.textSize))
        })

        // nueral background has a tag of 23 and any sibling or sibling child label should be light color
        $(UIImageView.self |^ { $0.tag == 23 } |+ UILabel.self, {
            $0.setFontColor(saucyTheme.lightColor)
        })
        $(UIImageView.self |^ { $0.tag == 23 } |+ UIView.self |> UILabel.self, {
            $0.setFontColor(saucyTheme.lightColor)
        })
        
        
        // headings
        $(UIViewController.self |>> UILabel.self |& T.first, {
            $0.setFontSize(CGFloat(saucyTheme.headingSize))
            $0.setFontName(saucyTheme.headingFont)
        })
        
        // packs and settings buttons on home page
        $(HomeController.self |> UITableView.self |+ UIView.self |^ { $0.tag == 23 }, {
            $0.setBackground(saucyTheme.fontColor)
        })
        $(HomeController.self |> UITableView.self |+ UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
            $0.setFontSize(CGFloat(saucyTheme.headingSize))
            $0.setFontName(saucyTheme.headingFont)
        })
        $(HomeController.self |> UITableView.self |> UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
        })
        
        // settings header
        $(UserSettingsController.self |> UITableViewHeaderFooterView.self, {
            $0.setBackground(saucyTheme.fontColor)
        })
        $(UserSettingsController.self |> UITableViewHeaderFooterView.self |> UILabel.self, {
            $0.setFontColor(saucyTheme.lightColor)
            $0.setFontName(saucyTheme.subheadingFont)
            $0.setFontSize(CGFloat(saucyTheme.subheadingSize))
        })

        // card button sizes
        // check and x font
        $([CardSelfController.self |> UIButton.self,
            CardSelfController.self |> UIButton.self |> UILabel.self,
            PackResultsController.self |> UIButton.self,
            PackResultsController.self |> UIButton.self |> UILabel.self], {
                $0.setFontSize(80)
        })
        // true and false button font
        $([CardTrueFalseController.self |> UIButton.self,
            CardTrueFalseController.self |> UIButton.self |> UILabel.self], {
                $0.setFontSize(40)
        })
        
        // This is the normal way to change appearance on a single type
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
    }
}