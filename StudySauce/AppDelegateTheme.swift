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
        |& psuedo-class matching like :first-child :last-child
        |@ Use device properties to determine if setting should apply
        Override Tag with string for className matching instead of stupid number
        [] list of TQueryable matches sets of rules
        */
        
        let saucyGray = UIColor(0xE9E9E9)
        let saucyFontColor = UIColor(0x424242)
        
        // set up font names
        $(UIButton.self, {
            $0.setFontName("Avenir-Medium")
        })
        
        // set up text colors
        $([UILabel.self,
           UITextView.self,
           UITextField.self], {
            // TODO: chaining would be nicer syntax here
            $0.setFontColor(saucyFontColor)
            $0.setFontName("Avenir-Medium")
            $0.setFontSize(17)
        })

        // nueral background has a tag of 23 and any sibling or sibling child label should be light color
        $(UIImageView.self |^ { $0.tag == 23 } |+ UILabel.self, { $0.setFontColor(saucyGray) })
        $(UIImageView.self |^ { $0.tag == 23 } |+ UIView.self |> UILabel.self, { $0.setFontColor(saucyGray) })
        
        // settings buttons on home page
        $(HomeController.self |> UITableView.self |+ UILabel.self, { $0.setFontColor(saucyFontColor) })
        $(HomeController.self |> UITableView.self |> UILabel.self, { $0.setFontColor(saucyFontColor) })
        
        // headings
        $(UIViewController.self |>> UILabel.self |& T.first, { $0.setFontSize(22) })
        
        $(UserSettingsController.self |> UITableViewHeaderFooterView.self, { $0.setBackground(saucyFontColor) })
        $(UserSettingsController.self |> UITableViewHeaderFooterView.self |> UILabel.self, {
            $0.setFontColor(saucyGray)
            $0.setFontSize(20)
        })

        // card button sizes
        $([CardSelfController.self |> UIButton.self,
            CardSelfController.self |> UIButton.self |> UILabel.self,
            PackResultsController.self |> UIButton.self,
            PackResultsController.self |> UIButton.self |> UILabel.self], { $0.setFontSize(80) })
        $([CardTrueFalseController.self |> UIButton.self,
            CardTrueFalseController.self |> UIButton.self |> UILabel.self], { $0.setFontSize(40) })
        
        // This is the normal way to change appearance on a single type
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
    }
}