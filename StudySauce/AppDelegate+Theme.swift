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
    static let primary = UIColor(0xFF9900)
    static let secondary = UIColor(0x2299BB)
    static let middle = UIColor(0xBBBBBB)
    
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
        |^ Use the view to match properties and psudo-classes like :first-child :last-child
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
        $(UITableView.self, {
            $0.backgroundColor = UIColor.clearColor()
            $0.separatorStyle = UITableViewCellSeparatorStyle.None
            $0.separatorColor = UIColor.clearColor()
        })
        $([UserSettingsContainerController.self |>> UILabel.self |^ T.firstOfType,
            PackSummaryController.self |>> UILabel.self |^ T.firstOfType,
            UIViewController.self |^ "Privacy" |>> UILabel.self |^ T.firstOfType,
            CardController.self |>> UILabel.self |^ T.firstOfType,
            PackResultsController.self |>> UILabel.self |^ T.firstOfType,
            ContactUsController.self |>> UILabel.self |^ T.firstOfType], {
                
                $0.setFontSize(CGFloat(saucyTheme.headingSize))
                $0.setFontName(saucyTheme.headingFont)
                $0.setFontColor(saucyTheme.lightColor)
                let s = $0.superview!
                let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50)) <| {
                    $0.backgroundColor = saucyTheme.fontColor
                }
                v.backgroundColor = saucyTheme.fontColor
                s.insertSubview(v, atIndex: 0)
                v.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
                v.translatesAutoresizingMaskIntoConstraints = false
                s.addConstraint(NSLayoutConstraint(
                    item: v,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: s,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1,
                    constant: 0))
                
                /*s.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[subview]|",
                options:[],
                metrics:nil,
                views:["subview" : v]));*/
                s.addConstraint(NSLayoutConstraint(item: v, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: s, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
                s.addConstraint(NSLayoutConstraint(item: v, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: s, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                s.addConstraint(NSLayoutConstraint(item: v, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: $0, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1, constant: 22))
                //v.layoutIfNeeded()
                UIApplication.sharedApplication().statusBarStyle = .LightContent
        })
        $(UserSettingsController.self |> UITableViewCell.self, {
            $0.tintColor = saucyTheme.primary
        })
        $([PackResultsController.self |>> UILabel.self |^ T.nthOfType(1),
            PackResultsController.self |>> UILabel.self |^ T.nthOfType(2)], {
            $0.setFontSize(30)
        })
        $(PackResultsController.self |>> UILabel.self |^ T.nthOfType(3), {
            $0.setFontSize(60)
            $0.setFontName(saucyTheme.headingFont)
            $0.setFontColor(saucyTheme.primary)
        })
        $(PackSummaryController.self |> UITableView.self, {
            $0.separatorColor = saucyTheme.middle
            $0.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        })
        $(PackSummaryCell.self |> UILabel.self |^ T.firstOfType, {
            $0.setFontName(saucyTheme.subheadingFont)
        })
        // packs and settings buttons on home page
        $(HomeController.self |> UITableView.self |+ UIView.self |^ { $0.tag == 23 }, {
            $0.setBackground(saucyTheme.fontColor)
        })
        $(HomeController.self |> UITableView.self |+ UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
            $0.setFontSize(CGFloat(saucyTheme.textSize))
            $0.setFontName(saucyTheme.subheadingFont)
        })
        $(HomeController.self |> UITableView.self |> UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
        })
        $([HomeController.self |> UITableView.self], {
            // Make the cell self size
            if let v = $0 as? UITableView {
                v.estimatedRowHeight = 30.0
                v.rowHeight = UITableViewAutomaticDimension
            }
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