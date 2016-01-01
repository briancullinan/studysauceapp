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
    static let padding = 10.0 * saucyTheme.multiplier()
    static let vertical: CGFloat = {
        let view = UIView()
        let sibling = NSLayoutConstraint.constraintsWithVisualFormat("[view]-[view]", options: [], metrics: nil, views: ["view" : view])
        return sibling.first!.constant   // 8.0
        
        //NSView* superview = [NSView new] ;
        //[superview addSubview:view] ;
        //NSLayoutConstraint* constraintWithStandardConstantBetweenSuperview = [NSLayoutConstraint constraintsWithVisualFormat:@"[view]-|"  options:0  metrics:nil  views:NSDictionaryOfVariableBindings(view) ] [0] ;
        //CGFloat standardConstantBetweenSuperview = constraintWithStandardConstantBetweenSuperview.constant ;    // 20.0
    }()
    
    static let buttonFont = "Avenir-Medium"
    
    static let textFont = "Avenir-Medium"
    static let textSize = 14.0 * saucyTheme.multiplier()
    
    static let headingFont = "Avenir-Heavy"
    static let headingSize = 15.0 * saucyTheme.multiplier()
    static let subheadingFont = "Avenir-Heavy"
    static let subheadingSize = 14 * saucyTheme.multiplier()
    static let labelFont = "Avenir-Heavy"
    static let lineHeight = CGFloat(1.8)
    
    static func multiplier () -> CGFloat {
        let result = min(UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width) / 300
        return result
    }
}

let manager = CMMotionManager()

var saucyBackground: UIWindow? = nil

extension AppDelegate {
    
    static func createHeading(label: UILabel) {
        let s = label.superview!
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50)) <| {
            $0.backgroundColor = saucyTheme.fontColor
            $0.tag = 24
        }
        v.backgroundColor = saucyTheme.fontColor
        s.insertSubview(v, belowSubview: label)
        s.sendSubviewToBack(v)
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
        s.addConstraint(NSLayoutConstraint(item: v, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: label, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    }
    
    func rotated()
    {
        if AppDelegate.instance().window != nil {
            doMain {
                let vc = AppDelegate.visibleViewController()
                if vc.getOrientation() != UIApplication.sharedApplication().statusBarOrientation {
                    vc.orientation = UIApplication.sharedApplication().statusBarOrientation
                    self.rerenderView(vc.view)
                }
            }
        }
    }
    
    func rerenderView(v: UIView) {
        v.setAppearanceFunc("")
        for s in v.subviews {
            rerenderView(s)
        }
    }
    
    static func createBlurView(v: UIView) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.tag = 23
        blurEffectView.frame = v.superview!.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurEffectView.backgroundColor = UIColor.clearColor()
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        v.superview!.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        
        v.superview!.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: v.superview!, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        v.superview!.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: v.superview!, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        v.superview!.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: v.superview!, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        v.superview!.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: v.superview!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        return blurEffectView
    }
    
    func setupTheme() {

        /*
        Key:
        ~>  Any descendent
        ~>> Direct descendent
        ~+  Sibling of last element
        ~*  Use the view to match properties and psudo-classes like :first-child :last-child
        []  List of TQueryable matches sets of rules
        |@  Use device properties to determine if setting should apply
        TODO: Override Tag with string for className matching instead of stupid number
        */
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIApplicationDidBecomeActiveNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        

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
            $0.setFontSize(saucyTheme.textSize)
        })
        
        $(UIImageView.self ~* {$0.tag == 23}, {background in
            background.hidden = true
            background.viewController()!.view.clipsToBounds = false
            if saucyBackground == nil {
                saucyBackground = UIWindow(frame: UIScreen.mainScreen().bounds)
                saucyBackground!.rootViewController = HomeController()

                let saucyImage = UIImageView(image: background.image)
                saucyBackground!.rootViewController!.view.addSubview(saucyImage)
                saucyImage.frame = background.superview!.bounds
                saucyImage.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                saucyImage.contentMode = UIViewContentMode.ScaleAspectFill
                saucyImage.translatesAutoresizingMaskIntoConstraints = false
                
                saucyBackground!.hidden = false
                self.window!.makeKeyAndVisible()
                
                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: saucyImage.superview!, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: saucyImage.superview!, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: saucyImage.superview!, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: saucyImage.superview!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            }
            //if manager.deviceMotionAvailable {
            //    manager.deviceMotionUpdateInterval = 0.01
            //    manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {(data: CMDeviceMotion?, error: NSError?) in
            //        let rotation = atan2(data!.gravity.x, data!.gravity.y) - M_PI
            //        saucyBackground!.rootViewController!.view.subviews.first!.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
            //    }
            //}

        })
        
        // headings
        $(UITableView.self, {
            $0.backgroundColor = UIColor.clearColor()
            $0.separatorStyle = UITableViewCellSeparatorStyle.None
            $0.separatorColor = UIColor.clearColor()
            $0.preservesSuperviewLayoutMargins = false
            $0.separatorInset = UIEdgeInsetsZero
            $0.layoutMargins = UIEdgeInsetsZero
        })
        
        $(UITableView.self ~> UITableViewCell.self, {
            $0.selectionStyle = .None
            $0.separatorInset = UIEdgeInsetsZero
            $0.layoutMargins = UIEdgeInsetsZero
        })
        

        // nueral background has a tag of 23 and any sibling or sibling child label should be light color
        $(UIViewController.self ~* {$0.modalPresentationStyle == .OverCurrentContext} ~>> UIView.self, {(v: UIView) in
            if (v.viewController()!.view! ~> UIVisualEffectView.self).count == 0 {
                if !UIAccessibilityIsReduceTransparencyEnabled() {
                    v.superview!.backgroundColor = UIColor.clearColor()
                    let blur = AppDelegate.createBlurView(v)
                    blur.superview!.sendSubviewToBack(blur)
                }
                else {
                    v.superview!.backgroundColor = UIColor.clearColor()
                }
            }
        })
        
        $([DialogController.self ~> UILabel.self,
           UIImageView.self ~* { $0.tag == 23 } ~+ UILabel.self], {
            $0.setFontColor(saucyTheme.lightColor)
        })
        
        $(UserSwitchController.self ~> UITableViewCell.self ~> UILabel.self, {
            $0.setFontName(saucyTheme.labelFont)
            $0.setFontColor(saucyTheme.fontColor)
        })
        
        $(UserSwitchController.self ~> UILabel.self ~* {$0.text == "✔︎"}, {
            $0.setFontSize(30 * saucyTheme.multiplier())
        })
        
        $(UserSwitchController.self ~> UITableView.self, {
            $0.separatorColor = saucyTheme.middle
            $0.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        })
        
        $([DialogController.self ~>> UILabel.self,
           UserInviteController.self ~>> UILabel.self,
           UserLoginController.self ~>> UILabel.self,
           UserResetController.self ~>> UILabel.self], {
            $0.setFontSize(30.0 * saucyTheme.multiplier())
        })
        
        $(UIViewController.self ~>> UILabel.self ~* {$0.tag == 25}, {(v: UILabel) -> Void in
            v.setFontSize(saucyTheme.headingSize)
            v.setFontName(saucyTheme.headingFont)
            v.setFontColor(saucyTheme.lightColor)
            if (v ~+ (UIView.self ~* {$0.tag == 24})).count == 0 && !v.hidden {
                AppDelegate.createHeading(v)
            }
            
        })
        
        $([PackResultsController.self ~>> UILabel.self ~* 1,
           PackResultsController.self ~>> UILabel.self ~* 3], {
            $0.setFontSize(30 * saucyTheme.multiplier())
            $0.setFontName(saucyTheme.headingFont)
        })
        
        $(PackResultsController.self ~>> UILabel.self ~* 2, {
            $0.setFontSize(60 * saucyTheme.multiplier())
            $0.setFontName(saucyTheme.headingFont)
            $0.setFontColor(saucyTheme.primary)
        })
        
        $([PackSummaryController.self ~> UITableView.self,
           UserSettingsController.self ~> UITableView.self], {(v: UITableView) in
            v.separatorColor = saucyTheme.middle
            v.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            // this doesn't work in appearence :(
            //v.estimatedRowHeight = 40.0 * saucyTheme.multiplier()
            //v.rowHeight = UITableViewAutomaticDimension
        })
        
        $(UserSettingsController.self ~> UITableViewCell.self ~>> UILabel.self ~* 1, {
            $0.setFontName(saucyTheme.labelFont)
        })

        $(PackSummaryCell.self ~> UILabel.self ~* 1, {
            $0.setFontName(saucyTheme.subheadingFont)
        })
        
        // packs and settings buttons on home page
        $([HomeController.self ~>> UIButton.self ~* {$0.tag == 1337}], {(v: UIButton) in
            v.contentEdgeInsets = UIEdgeInsetsMake(
                0,
                saucyTheme.textSize * 1.5 / 2,
                saucyTheme.textSize * 1.5,
                saucyTheme.textSize * 1.5 / 2)
        })
        
        $(HomeController.self ~> UITableView.self ~+ UIView.self ~* {$0.tag == 2}, {
            $0.setBackground(saucyTheme.fontColor)
        })
        
        $(HomeController.self ~> UITableView.self ~+ UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
            $0.setFontSize(saucyTheme.textSize)
            $0.setFontName(saucyTheme.subheadingFont)
        })
        
        $(HomeController.self ~> UITableView.self ~> UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
        })

        $(HomeController.self ~> UIButton.self ~* {$0.tag == 1}, {
            $0.setFontColor(saucyTheme.primary)
        })

        // settings header
        $(UserSettingsController.self ~> UITableViewHeaderFooterView.self, {
            $0.setBackground(saucyTheme.fontColor)
        })
        
        $(UserSettingsController.self ~> UITableViewHeaderFooterView.self ~> UILabel.self, {
            $0.setFontColor(saucyTheme.lightColor)
            $0.setFontName(saucyTheme.subheadingFont)
            $0.setFontSize(saucyTheme.subheadingSize)
        })
        
        // card button sizes
        // check and x font
        $([CardSelfController.self ~> UIButton.self,
           CardSelfController.self ~> UIButton.self ~> UILabel.self,
           PackResultsController.self ~> UIButton.self ~* {$0.tag == 2},
           PackResultsController.self ~> UIButton.self ~* {$0.tag == 2} ~> UILabel.self], {
            $0.setFontSize(40 * saucyTheme.multiplier())
        })
        
        // true and false button font
        $([CardTrueFalseController.self ~> UIButton.self,
           CardTrueFalseController.self ~> UIButton.self ~> UILabel.self], {
            $0.setFontSize(30 * saucyTheme.multiplier())
        })
        
        $([CardBlankController.self ~> UITextField.self,
            CardBlankController.self ~> UITextField.self ~> UILabel.self], {
            $0.setFontSize(20 * saucyTheme.multiplier())
        })
        
        $(ContactUsController.self ~> UITextView.self, {
            $0.backgroundColor = UIColor.whiteColor()
            $0.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
            $0.layer.borderWidth = 0.5
            $0.layer.cornerRadius = 0
            $0.textContainerInset = UIEdgeInsets(saucyTheme.padding)
        })
        
        $(UITextField.self ~>> UILabel.self, {
            if $0.text == ($0.superview as? UITextField)?.placeholder {
                $0.setFontColor(saucyTheme.lightColor)
            }
        })
        
        $([CardBlankController.self ~> UITextField.self,
            ContactUsController.self ~> UITextField.self], {(v: UITextField) in
            v.backgroundColor = UIColor.whiteColor()
            v.borderStyle = UITextBorderStyle.None
            v.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
            v.layer.borderWidth = 0.5
            v.layer.cornerRadius = 0
        })
        
        $([UIViewController.self ~* "Privacy" ~> UITextView.self,
            UIViewController.self ~* "About" ~> UITextView.self], {(v: UITextView) in
                doMain {
                    v.scrollRangeToVisible(NSMakeRange(0, 0))
                }
        })
        
        $([CardPromptController.self ~> UITextView.self,
            CardResponseController.self ~> UITextView.self], {
                $0.setFontSize(30.0 * saucyTheme.multiplier())
                $0.superview?.sendSubviewToBack($0)
        })
        
        $([CardPromptController.self ~> UITextView.self ~* T.device("ipad"),
            CardResponseController.self ~> UITextView.self ~* T.device("ipad")], {
                $0.setFontSize(40.0 * saucyTheme.multiplier())
        })
        
        $([CardPromptController.self ~> UITextView.self,
            CardResponseController.self ~> UITextView.self,
            UIViewController.self ~* "Privacy" ~> UITextView.self,
            UIViewController.self ~* "About" ~> UITextView.self], {(v: UITextView) in
            v.textContainerInset = UIEdgeInsets(saucyTheme.padding * 2)
        })
        
        $(UIViewController.self ~> UIButton.self ~* {$0.tag == 1338}, {(v: UIButton) in
                v.setFontName(saucyTheme.textFont)
                v.setFontColor(saucyTheme.lightColor)
                v.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding * 2, saucyTheme.padding)
        })
        
        $([CardController.self ~>> UIView.self,
            PackSummaryController.self ~>> UIView.self,
            UserSettingsController.self ~>> UIView.self,
            UIViewController.self ~* "Privacy" ~>> UIView.self,
            UIViewController.self ~* "About" ~>> UIView.self,
            ContactUsController.self ~>> UIView.self], {
                
            $0.viewController()!.view.backgroundColor = saucyTheme.lightColor
        })
        
        $(TutorialPageViewController.self ~>> UIButton.self ~* {$0.tag == 26}, {
            $0.setFontColor(saucyTheme.lightColor)
        })
        
        $(UIViewController.self ~>> UIButton.self ~* {$0.tag == 26}, {
            $0.contentMode = .ScaleAspectFit
        })
        
        var combos: [Dictionary<String,UIColor>] = []
        let colors = [saucyTheme.primary, saucyTheme.secondary, saucyTheme.lightColor, saucyTheme.middle, saucyTheme.fontColor]
        for c in colors {
            for c2 in colors.filter({$0 != c}) {
                combos.append(["background": c, "foreground": c2])
            }
        }
        
        $(DACircularProgressView.self, {
            $0.trackTintColor = saucyTheme.middle
            $0.progressTintColor = saucyTheme.secondary
        })
        
        $(UserSwitchController.self ~> FaceView.self, {
            let combo = Int(arc4random_uniform(UInt32(combos.count)))
            $0.backgroundColor = combos[combo]["background"]
            $0.color = combos[combo]["foreground"]!
            $0.smiliness = Double(Int(arc4random_uniform(UInt32(50))))/50
        })
        
        $(TutorialContentViewController.self ~> UILabel.self, {
            $0.setFontColor(saucyTheme.lightColor)
            $0.setFontSize(20 * saucyTheme.multiplier())
        })
        
        $(TutorialContentViewController.self ~> UILabel.self ~* {$0.tag == 1}, {
            $0.setFontColor(saucyTheme.primary)
            $0.setFontSize(40 * saucyTheme.multiplier())
        })
        
        $(TutorialPageViewController.self ~> UIScrollView.self, {
            $0.alwaysBounceHorizontal = false
            $0.bounces = false
        })
        
        $(TutorialPageViewController.self ~> UIPageControl.self, {
            
            $0.pageIndicatorTintColor = saucyTheme.lightColor
            $0.currentPageIndicatorTintColor = saucyTheme.primary
            $0.backgroundColor = saucyTheme.fontColor

        })

        // This is the normal way to change appearance on a single type
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
    }
}