//
//  AppDelegateTheme.swift
//  StudySauce
//
//  Created by Stephen Houghton on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

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

let manager = CMMotionManager()

var saucyBackground: UIWindow? = nil

extension AppDelegate {
    func createHeading(label: UILabel) {
        let s = label.superview!
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50)) <| {
            $0.backgroundColor = saucyTheme.fontColor
            $0.tag = 24
        }
        v.backgroundColor = saucyTheme.fontColor
        s.insertSubview(v, belowSubview: label)
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
        s.addConstraint(NSLayoutConstraint(item: v, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: s, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        s.addConstraint(NSLayoutConstraint(item: v, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: s, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        s.addConstraint(NSLayoutConstraint(item: v, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: label, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: CGFloat(14.0)))
    }

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
        UIApplication.sharedApplication().statusBarStyle = .LightContent

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
        
        $(UIImageView.self |^ {$0.tag == 23}, {background in
            background.hidden = true
            background.viewController()!.view.clipsToBounds = false
            if saucyBackground == nil {
                let max = UIScreen.mainScreen().bounds.height > UIScreen.mainScreen().bounds.width ? UIScreen.mainScreen().bounds.height : UIScreen.mainScreen().bounds.width
                saucyBackground = UIWindow(frame: UIScreen.mainScreen().bounds)
                saucyBackground!.rootViewController = HomeController()
                let saucyImage = UIImageView(image: background.image)
                saucyBackground!.rootViewController!.view.addSubview(saucyImage)
                saucyImage.frame = CGRect(x: 0, y: 0, width: max, height: max)
                saucyImage.contentMode = UIViewContentMode.ScaleAspectFill
                saucyImage.translatesAutoresizingMaskIntoConstraints = false
                saucyBackground!.hidden = false
                self.window!.makeKeyAndVisible()
            }
            //if manager.deviceMotionAvailable {
            //    manager.deviceMotionUpdateInterval = 0.01
            //    manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {(data: CMDeviceMotion?, error: NSError?) in
            //        let rotation = atan2(data!.gravity.x, data!.gravity.y) - M_PI
            //        saucyBackground!.rootViewController!.view.subviews.first!.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
            //    }
            //}

        })
        
        // nueral background has a tag of 23 and any sibling or sibling child label should be light color
        $([DialogController.self |> UILabel.self,
           UIImageView.self |^ { $0.tag == 23 } |+ UILabel.self], {
            $0.setFontColor(saucyTheme.lightColor)
        })
        $([DialogController.self |>> UILabel.self |^ T.firstOfType,
           UserInviteController.self |>> UILabel.self |^ T.firstOfType,
           UserLoginController.self |>> UILabel.self |^ T.firstOfType,
           UserResetController.self |>> UILabel.self |^ T.firstOfType], {
            $0.setFontSize(30.0)
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
           ContactUsController.self |>> UILabel.self |^ T.firstOfType], {(v: UILabel) -> Void in
            
            v.tag = 25
            v.setFontSize(CGFloat(saucyTheme.headingSize))
            v.setFontName(saucyTheme.headingFont)
            v.setFontColor(saucyTheme.lightColor)
            if (v |+ (UIView.self |^ {$0.tag == 24})).count == 0 {
                self.createHeading(v)
            }
            
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
        $([PackSummaryController.self |> UITableView.self,
           UserSettingsController.self |> UITableView.self], {(v: UITableView) -> Void in
            v.separatorColor = saucyTheme.middle
            v.preservesSuperviewLayoutMargins = false
            v.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            v.separatorInset = UIEdgeInsetsZero
        })
        $([PackSummaryController.self |> UITableView.self |> UITableViewCell.self,
           UserSettingsController.self |> UITableView.self |> UITableViewCell.self], {(v: UITableViewCell) -> Void in
            v.preservesSuperviewLayoutMargins = false
            v.layoutMargins = UIEdgeInsetsZero
            v.separatorInset = UIEdgeInsetsZero
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
        $([HomeController.self |> UITableView.self], {(v: UITableView) -> Void in
            // Make the cell self size
            v.estimatedRowHeight = 30.0
            v.rowHeight = UITableViewAutomaticDimension
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
        $([CardBlankController.self |> UITextField.self,
            CardBlankController.self |> UITextField.self |> UILabel.self], {
            $0.setFontSize(20)
        })
        $(ContactUsController.self |> UITextView.self, {
            $0.backgroundColor = UIColor.whiteColor()
            $0.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
            $0.layer.borderWidth = 0.5
            $0.layer.cornerRadius = 0
        })
        $(UITextField.self |>> UILabel.self, {
            if $0.text == ($0.superview as? UITextField)?.placeholder {
                $0.setFontColor(saucyTheme.lightColor)
            }
        })
        $([CardBlankController.self |> UITextField.self,
            ContactUsController.self |> UITextField.self], {(v: UITextField) in
            v.backgroundColor = UIColor.whiteColor()
            v.borderStyle = UITextBorderStyle.None
            v.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
            v.layer.borderWidth = 0.5
            v.layer.cornerRadius = 0
        })
        
        //$(|^{$0.systemVersion.compare("8.0", options: .NumericSearch) == .OrderedDescending} |> UILabel.self, {
        //    $0.setFontColor(UIColor.blueColor())
        //})
        
        // This is the normal way to change appearance on a single type
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
    }
}