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
    static let textSize = ceil(14.0 * saucyTheme.multiplier())
    
    static let headingFont = "Avenir-Heavy"
    static let headingSize = ceil(15.0 * saucyTheme.multiplier())
    static let subheadingFont = "Avenir-Heavy"
    static let subheadingSize = ceil(14 * saucyTheme.multiplier())
    static let labelFont = "Avenir-Heavy"
    static let lineHeight = CGFloat(1.8)
    
    static func multiplier () -> CGFloat {
        let result = min(768.0, min(UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width)) / 300.0
        return result
    }
}

let manager = CMMotionManager()

var saucyBackground: UIWindow? = nil

extension AppDelegate {
    
    static func createHeading(label: UILabel) {
        let s = label.superview!
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50)) <| {
            $0.tag = 24
        }
        s.insertSubview(v, belowSubview: label)
        s.sendSubviewToBack(v)
       
        // do constraint stuff
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
        s.addConstraint(NSLayoutConstraint(
            item: v,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: s,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1,
            constant: 0))
        s.addConstraint(NSLayoutConstraint(
            item: v,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: s,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0))
        s.addConstraint(NSLayoutConstraint(
            item: v,
            attribute: NSLayoutAttribute.BottomMargin,
            relatedBy: NSLayoutRelation.Equal,
            toItem: label,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0))
        
        // do customization stuff
        v.backgroundColor = saucyTheme.fontColor
        if let card = (v.viewController() as? CardController) {
            if let pack = card.pack {
                if let background = pack.getProperty("background-color") as? Int {
                    v.backgroundColor = UIColor(background)
                }
                if let image = pack.getProperty("background-image") as? String {
                    File.save(image, done: {(f:File) in
                        doMain {
                            let fileManager = NSFileManager.defaultManager()
                            if let data = fileManager.contentsAtPath(f.filename!) {
                                let saucyImage = UIImageView(image: UIImage(data: data))
                                card.view.addSubview(saucyImage)
                                card.view.sendSubviewToBack(saucyImage)
                                saucyImage.tag = 26
                                saucyImage.frame = card.embeddedView.bounds
                                saucyImage.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                saucyImage.contentMode = UIViewContentMode.ScaleAspectFill
                                saucyImage.translatesAutoresizingMaskIntoConstraints = false
                                
                                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: card.embeddedView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
                                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: card.embeddedView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
                                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: card.embeddedView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                                saucyImage.superview!.addConstraint(NSLayoutConstraint(item: saucyImage, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: card.embeddedView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
                            }
                        }
                    })
                }
            }
        }

    }
    
    func rotated()
    {
        if AppDelegate.instance().window != nil {
            if !self.isRotating {
                self.isRotating = true
                doMain {
                    let vc = AppDelegate.visibleViewController()
                    if vc.getOrientation() != UIApplication.sharedApplication().statusBarOrientation {
                        vc.orientation = UIApplication.sharedApplication().statusBarOrientation
                        if !vc.view.hidden {
                            AppDelegate.rerenderView(vc.view)
                        }
                    }
                    self.isRotating = false
                }
            }
        }
    }
    
    func keyboard()
    {
        if AppDelegate.instance().window != nil {
            if !self.isRotating {
                self.isRotating = true
                doMain {
                    let vc = AppDelegate.visibleViewController()
                    if vc.getOrientation() != UIApplication.sharedApplication().statusBarOrientation {
                        vc.orientation = UIApplication.sharedApplication().statusBarOrientation
                        if !vc.view.hidden {
                            AppDelegate.rerenderView(vc.view)
                        }
                    }
                    self.isRotating = false
                }
            }
        }
    }
    
    static func setAnalytics() {
        if AppDelegate.instance().window != nil {
            let vc = AppDelegate.visibleViewController()
            let tracker = GAI.sharedInstance().defaultTracker
            let name = vc.getAnalytics()
            if name != tracker.get(kGAIScreenName) {
                tracker.set(kGAIScreenName, value: name)
                let builder = GAIDictionaryBuilder.createScreenView()
                tracker.send(builder.build() as [NSObject : AnyObject])
            }
        }
    }
    
    static func rerenderView(v: UIView) {
        v.setAppearanceFunc("")
        for s in v.subviews {
            self.rerenderView(s)
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
    
    func buttonTapped(button: UIButton) {
        doMain {
            AppDelegate.rerenderView(button)
        }
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
                    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.rotated), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.keyboard), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.keyboard), name: UIKeyboardDidHideNotification, object: nil)
        
        
        if let window = AppDelegate.instance().window {
            window.backgroundColor = UIColor.clearColor()
            window.opaque = false
            window.makeKeyAndVisible();
        }
        
        // set up font names
        $(UIButton.self, {
            $0.addTarget(self, action: #selector(AppDelegate.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchDown)
            $0.addTarget(self, action: #selector(AppDelegate.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            $0.addTarget(self, action: #selector(AppDelegate.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        })
        
        $(UIViewController.self ~>> UIView.self, {_ in
            AppDelegate.setAnalytics()
        })
        
        // set up text colors
        $([UIButton.self,
           UILabel.self,
           UITextView.self,
           UITextField.self], {
            // TODO: chaining would be nicer syntax here
            $0.setFontColor(saucyTheme.fontColor)
            $0.setFontName(saucyTheme.textFont)
            $0.setFontSize(saucyTheme.textSize)
        })
        
        $([UIViewController.self ~> UIButton.self,
            UIViewController.self ~> UIButton.self ~> UILabel.self], {
                $0.setFontColor(saucyTheme.lightColor)
        })
        
        $(UIViewController.self ~* "About" ~>> UITextView.self) {
            let newPara = NSMutableParagraphStyle()
            newPara.defaultTabInterval = 10.5
            newPara.paragraphSpacing = 4
            newPara.paragraphSpacingBefore = 4
            newPara.firstLineHeadIndent = 0.0
            newPara.headIndent = 10.5
            newPara.lineSpacing = saucyTheme.padding
            $0.attributedText.replaceAttribute(NSParagraphStyleAttributeName, newPara)
        }
        
        $(UIImageView.self ~* 23, {background in
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
           UIImageView.self ~* 23 ~+ UILabel.self], {
            $0.setFontColor(saucyTheme.lightColor)
        })
        
        $(UserSwitchController.self ~> UITableViewCell.self ~> UILabel.self, {
            $0.setFontName(saucyTheme.labelFont)
            $0.setFontColor(saucyTheme.fontColor)
        })
        
        $(UserSwitchController.self ~> UILabel.self ~* {$0.text == "✔︎"}, {
            $0.setFontSize(25 * saucyTheme.multiplier())
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
        
        $(UIViewController.self ~>> UILabel.self ~* 25, {(v: UILabel) -> Void in
            v.setFontSize(saucyTheme.headingSize)
            v.setFontName(saucyTheme.headingFont)
            v.setFontColor(saucyTheme.lightColor)
            if (v ~+ (UIView.self ~* 24)).count == 0 && !v.hidden {
                AppDelegate.createHeading(v)
            }
            
        })
        
        $([StoreController.self ~> UILabel.self ~* 3,
            PackResultsController.self ~>> UILabel.self ~* 1,
           PackResultsController.self ~>> UILabel.self ~* 3], {
            $0.setFontSize(30 * saucyTheme.multiplier())
            $0.setFontName(saucyTheme.headingFont)
        })
        
        $([StoreController.self ~> UILabel.self ~* 2,
          PackResultsController.self ~>> UILabel.self ~* 2], {
            $0.setFontSize(60 * saucyTheme.multiplier())
            $0.setFontName(saucyTheme.headingFont)
            $0.setFontColor(saucyTheme.primary)
        })
        
        $([StoreController.self ~> UILabel.self ~* 2,
            PackResultsController.self ~>> UILabel.self ~* 2 ~* T.orientation("landscape")], {
            $0.setFontSize(40 * saucyTheme.multiplier())
        })
        
        $([PackResultsController.self ~>> UILabel.self ~* 1 ~* T.orientation("landscape"),
            PackResultsController.self ~>> UILabel.self ~* 3 ~* T.orientation("landscape")], {
                $0.setFontSize(20 * saucyTheme.multiplier())
        })
        $([PackResultsController.self ~>> UILabel.self ~* 1 ~* T.size(.Unspecified, .Compact),
            PackResultsController.self ~>> UILabel.self ~* 3 ~* T.size(.Unspecified, .Compact)], {
            $0.setFontSize(20 * saucyTheme.multiplier())
        })
        $([PackResultsController.self ~>> UILabel.self ~* 1 ~* T.size(.Compact, .Unspecified),
            PackResultsController.self ~>> UILabel.self ~* 3 ~* T.size(.Compact, .Unspecified)], {
                $0.setFontSize(20 * saucyTheme.multiplier())
        })
        
        $([StoreController.self ~> UITableView.self,
           PackSummaryController.self ~> UITableView.self,
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

        $([PackSummaryCell.self ~> UILabel.self ~* 1], {
            $0.setFontName(saucyTheme.subheadingFont)
        })
        
        // packs and settings buttons on home page
        $([HomeController.self ~>> UIButton.self ~* 1337]) {(v: UIButton) in
            v.contentEdgeInsets = UIEdgeInsetsMake(
                0,
                saucyTheme.textSize * 1.5 / 2,
                saucyTheme.textSize * 1.5,
                saucyTheme.textSize * 1.5 / 2)
        }
        
        // borders
        $(HomeController.self ~> UITableView.self ~+ UIView.self ~* 2, {
            $0.setBackground(saucyTheme.fontColor)
        })
        
        // borders
        $(CardResponseController.self ~> UIView.self ~* 18, {
            $0.setBackground(saucyTheme.middle)
        })
        
        $(UserSwitchController.self ~> UITableViewCell.self ~* "empty" ~> UIView.self ~* 2, {
            $0.setBackground(saucyTheme.middle)
        })
        
        $(HomeController.self ~> UITableView.self ~+ UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
            $0.setFontSize(saucyTheme.textSize)
            $0.setFontName(saucyTheme.subheadingFont)
        })

        $(HomeController.self ~> UITableView.self ~> UILabel.self, {
            $0.setFontColor(saucyTheme.fontColor)
        })

        $(HomeController.self ~> UIButton.self ~* 1, {
            $0.setFontColor(saucyTheme.primary)
        })
        
        $(HomeController.self ~> UIButton.self ~* "signup", {
            $0.backgroundColor = saucyTheme.primary
        })

        $(HomeController.self ~> PackRetentionCell.self ~> UILabel.self ~* 10, {
            $0.setFontColor(UIColor.redColor())
            $0.setFontSize(saucyTheme.textSize * 0.75)
            $0.setFontName(saucyTheme.subheadingFont)
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
            PackResultsController.self ~> UIButton.self ~* 2], {(v: UIButton) in
                v.setFontSize(40 * saucyTheme.multiplier())
                v.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding * 2)
                v.titleEdgeInsets = UIEdgeInsets(-saucyTheme.padding * 2)
        })

        $([CardSelfController.self ~> UIButton.self,
           CardSelfController.self ~> UIButton.self ~> UILabel.self,
           PackResultsController.self ~> UIButton.self ~* 2,
           PackResultsController.self ~> UIButton.self ~* 2 ~> UILabel.self], {
            $0.setFontSize(40 * saucyTheme.multiplier())
        })
        
        $([CardSelfController.self ~> UILabel.self ~* 5,
            CardResponseController.self ~> UILabel.self ~* 5,
            CardResponseController.self ~> UILabel.self ~* 55], {
            $0.setFontColor(saucyTheme.middle)
        })
        
        // true and false button font
        $(CardTrueFalseController.self ~> UIButton.self ~> UILabel.self, {
            $0.setFontSize(30 * saucyTheme.multiplier())
        })

        // true and false button font
        $(CardTrueFalseController.self ~> UIButton.self, {
            $0.setFontSize(30 * saucyTheme.multiplier())
            $0.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding)
            $0.titleEdgeInsets = UIEdgeInsets(-saucyTheme.padding)
        })
        
        $([CardBlankController.self ~> UITextField.self,
            CardBlankController.self ~> UITextField.self ~> UILabel.self], {
            $0.setFontSize(20 * saucyTheme.multiplier())
        })
        
        $([CardBlankController.self ~> UITextField.self ~* T.orientation("landscape"),
            CardBlankController.self ~> UITextField.self ~> UILabel.self ~* T.orientation("landscape"),
            CardBlankController.self ~> UITextField.self ~* T.device("ipad"),
            CardBlankController.self ~> UITextField.self ~> UILabel.self ~* T.device("ipad")], {
                $0.setFontSize(saucyTheme.textSize)
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
        
        $([StoreController.self ~> UITextField.self ~>> UILabel.self,
            CardBlankController.self ~> UITextField.self ~>> UILabel.self
//            ContactUsController.self ~> UITextField.self ~>> UILabel.self  Contact us uses labels instead of placeholders
            ], {(v: UILabel) in
            if v.text == (v.superview as? UITextField)?.placeholder {
                v.setFontColor(saucyTheme.middle)
            }
        })
        
        $([StoreController.self ~> UITextField.self,
            CardBlankController.self ~> UITextField.self,
            ContactUsController.self ~> UITextField.self], {(v: UITextField) in
            v.backgroundColor = UIColor.whiteColor()
            v.borderStyle = UITextBorderStyle.None
            v.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
            v.layer.borderWidth = 0.5
            v.layer.cornerRadius = 0
        })
        
        $([UIViewController.self ~* "Privacy" ~> UITextView.self,
            UIViewController.self ~* "About" ~> UITextView.self,
            CardPromptController.self ~> UITextView.self,
            CardResponseController.self ~> UITextView.self], {(v: UITextView) in
                doMain {
                    v.scrollRangeToVisible(NSMakeRange(0, 0))
                }
        })
        
        $([CardPromptController.self ~> UITextView.self,
            CardResponseController.self ~> UITextView.self,
            UIViewController.self ~* "Privacy" ~> UITextView.self,
            UIViewController.self ~* "About" ~> UITextView.self], {(v: UITextView) in
                v.textContainerInset = UIEdgeInsets(saucyTheme.padding, 0.0)
        })

        $([CardPromptController.self ~> UITextView.self,
            CardResponseController.self ~> UITextView.self], {(v: UITextView) in
                if v.tag == 450347 {
                    v.setFontSize(saucyTheme.textSize * 1.4)
                }
                else {
                    v.setFontSize(30.0 * saucyTheme.multiplier())
                }
                
                // align listen button to substring
                let content = v.attributedText.string as NSString
                let wholeRange = NSMakeRange(0, content.length)
                let range = content.rangeOfString("P14y", options: [], range: wholeRange)
                
                if range.length > 0 {
                    let attr = NSMutableAttributedString(attributedString: v.attributedText)
                    attr.addAttribute(NSFontAttributeName, value: UIFont(name: v.font!.fontName, size: 60.0 * saucyTheme.multiplier())!, range: range)
                    attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.clearColor(), range: range)
                    v.attributedText = NSAttributedString(attributedString: attr)
                }
                
                (v.viewController() as? CardPromptController)?.alignPlay(v)
        })
        
        $(CardResponseController.self ~> UITextView.self ~* 450347, {
            $0.textContainerInset = UIEdgeInsets(saucyTheme.padding * 2)
        })

        $([CardPromptController.self ~> UIButton.self ~* {$0.tag == 1},
            CardResponseController.self ~> UIButton.self ~* {$0.tag == 1}], {(v: UIButton) in
            let image = v.backgroundImageForState(.Normal)?.imageWithAlignmentRectInsets(UIEdgeInsets(-saucyTheme.padding))
            v.setBackgroundImage(image, forState: .Normal)
        })
        
        $(CardResponseController.self ~> UILabel.self, {
            $0.setFontSize(saucyTheme.headingSize)
        })
        
        $(UIViewController.self ~> UIButton.self ~* 1338, {(v: UIButton) in
            v.backgroundColor = saucyTheme.secondary
            v.setFontName(saucyTheme.textFont)
            v.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding * 2, saucyTheme.padding)
            v.titleEdgeInsets = UIEdgeInsets(-saucyTheme.padding * 2, -saucyTheme.padding)
        })
        
        $(StoreController.self ~> UIButton.self ~* 1338) {
            $0.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding * 0.5, saucyTheme.padding)
            $0.titleEdgeInsets = UIEdgeInsets(-saucyTheme.padding * 0.5, -saucyTheme.padding)
        }
        
        $(StoreController.self ~> TextField.self) {
            $0.padding = UIEdgeInsets(saucyTheme.padding * 0.5)
        }
        
        $(UIViewController.self ~> UIButton.self ~* 1339, {(v: UIButton) in
            v.backgroundColor = saucyTheme.primary
            v.setFontName(saucyTheme.textFont)
            v.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding * 2, saucyTheme.padding)
            v.titleEdgeInsets = UIEdgeInsets(-saucyTheme.padding * 2, -saucyTheme.padding)
        })
        
        $(UIViewController.self ~> UIButton.self ~* 1330, {
            $0.setFontColor(saucyTheme.secondary)
        })
        
        $(UIViewController.self ~> UIButton.self ~* 1338 ~* {!$0.enabled}, {
            $0.backgroundColor = saucyTheme.middle
        })
        
        $([CardController.self ~>> UIView.self,
            PackSummaryController.self ~>> UIView.self,
            UserSettingsController.self ~>> UIView.self,
            UIViewController.self ~* "Privacy" ~>> UIView.self,
            UIViewController.self ~* "About" ~>> UIView.self,
            ContactUsController.self ~>> UIView.self], {
                
            $0.viewController()!.view.backgroundColor = saucyTheme.lightColor
        })
        
        $(CardController.self ~>> UILabel.self ~* 1, {
            $0.setFontColor(saucyTheme.middle)
        })
        
        $(UIViewController.self ~>> UIButton.self ~* 26, {
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
        
        $(TutorialContentViewController.self ~> UILabel.self ~* 1, {
            $0.setFontColor(saucyTheme.primary)
            $0.setFontSize(30 * saucyTheme.multiplier())
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
        
        $(PackSummaryController.self ~> UITableViewCell.self ~* "Store" ~> UILabel.self, {
            $0.setFontColor(saucyTheme.secondary)
        })
        
        $(UserSwitchController.self ~> UITableViewCell.self ~* "empty" ~> UILabel.self, {
            $0.alpha = 0.75
            $0.setFontSize(saucyTheme.textSize * 0.75)
        })
        
        $(UserSwitchController.self ~> UITableViewCell.self ~* "empty" ~> UIImageView.self, {
            $0.alpha = 0.75
        })
        
        // keyboard styling
        $(BasicKeyboardController.self ~>> UIView.self, {
            $0.viewController()?.view.backgroundColor = saucyTheme.middle
        })
        
        $(BasicKeyboardController.self ~> UIButton.self, {
            $0.setFontName(saucyTheme.textFont)
            $0.setFontSize(saucyTheme.textSize * 1.5)
            $0.setFontColor(saucyTheme.fontColor)
            //$0.setTitleColor(saucyTheme.lightColor, forState: UIControlState.Highlighted)
            $0.layer.cornerRadius = 0
            $0.layer.borderColor = saucyTheme.middle.CGColor
            $0.layer.borderWidth = 1
            $0.backgroundColor = saucyTheme.lightColor
            $0.tintColor = UIColor.whiteColor()
            $0.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding)
            $0.titleEdgeInsets = UIEdgeInsets(-saucyTheme.padding)
        })
        
        $(BasicKeyboardController.self ~> UIButton.self ~> UILabel.self, {
            $0.setFontName(saucyTheme.textFont)
            $0.setFontSize(saucyTheme.textSize * 1.5)
            $0.setFontColor(saucyTheme.fontColor)
        })
        
        $([BasicKeyboardController.self ~> UIButton.self ~* 5,
            BasicKeyboardController.self ~> UIButton.self ~* {$0.highlighted}], {
            $0.backgroundColor = saucyTheme.secondary
            $0.setFontColor(saucyTheme.lightColor)
        })
        
        $(BasicKeyboardController.self ~> UIButton.self ~* 2, {
            if ($0.viewController() as! BasicKeyboardController).lowercase {
                
            }
            else {
                $0.backgroundColor = saucyTheme.secondary
                $0.setFontColor(saucyTheme.lightColor)
            }
        })
        
        $([UILabel.self ~* 59]) {(v: UILabel) in
            v.setFontColor(saucyTheme.primary)
            v.superview?.bringSubviewToFront(v)
            v.setFontName(saucyTheme.subheadingFont)
        }
        
        $(StoreController.self ~> UIView.self ~* 57 ~>> UILabel.self) {
            $0.setFontColor(UIColor(0x44AA44))
            $0.setFontName(saucyTheme.subheadingFont)
        }
        
        $(StoreController.self ~> UIView.self ~* 57 ~> UIButton.self) {
            $0.setBackground(saucyTheme.primary)
        }
        
        $(StoreController.self ~> UILabel.self ~* 56 ~+ UIButton.self) {
            $0.setBackground(UIColor(0x1d1c1b))
            $0.contentEdgeInsets = UIEdgeInsets(saucyTheme.padding * 0.5)
            $0.titleEdgeInsets = UIEdgeInsets(-saucyTheme.padding * 0.5)
        }
        
        $(StoreController.self ~> UILabel.self ~* 56) {
            $0.setFontName(saucyTheme.subheadingFont)
            $0.layer.addBorder(UIRectEdge.Top, color: saucyTheme.fontColor, thickness: 2)
        }
        
        $(UserSettingsController.self ~> UITableViewCell.self ~* "childLast") {
            $0.layer.addBorder(UIRectEdge.Bottom, color: saucyTheme.fontColor, thickness: 2)
        }
        
        $(StoreController.self ~> UIView.self ~* 57) {
            $0.addBorder(UIRectEdge.Bottom, color: saucyTheme.fontColor, thickness: 1)
        }

        $([StoreController.self ~> CouponCell.self ~> TextField.self,
            UserAddController.self ~> TextField.self ~* 90])
        {(v: TextField) in
            if (v ~> (UIImageView.self ~* 50)).count == 0 {
            let img = UIImageView(image: UIImage(named: "down_arrow"))
            img.tag = 50
            img.contentMode = UIViewContentMode.ScaleAspectFit
            img.translatesAutoresizingMaskIntoConstraints = false
            img.userInteractionEnabled = false
            v.addSubview(img)
            v.addConstraint(NSLayoutConstraint(
                    item: img,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: v,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0))
            v.addConstraint(NSLayoutConstraint(
                item: v,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: img,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1,
                constant: 10))
            img.addConstraint(NSLayoutConstraint(
                item: img,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1,
                constant: saucyTheme.textSize))
            }
        }
        
        // This is the normal way to change appearance on a single type
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
    }
}