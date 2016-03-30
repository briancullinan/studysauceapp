//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Tope Abayomi on 19/09/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import UIKit

class BasicKeyboardController: UIInputViewController {

    var lowercase = false {
        didSet {
            if let shift = (self.view ~> (UIButton.self ~* 2)).first {
                AppDelegate.rerenderView(shift)
            }
        }
    }
    
    static var keyboardHeight = CGFloat(0.0)
 
    static var _basic: BasicKeyboardController? = nil
    static var _basicNumbers: BasicKeyboardController? = nil
    static var _symbols1: BasicKeyboardController? = nil
    static var _symbols2: BasicKeyboardController? = nil
    
    static var basicKeyboard : UIView {
        if _basic == nil {
            _basic = AppDelegate.instance().storyboard!.instantiateViewControllerWithIdentifier("BasicKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRectMake(0, 0, AppDelegate.instance().window!.screen.bounds.width, height)
            _basic!.view!.frame = size
            _basic!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basic!.view!
    }
    
    static var symbols1Keyboard : UIView {
        if _symbols1 == nil {
            _symbols1 = AppDelegate.instance().storyboard!.instantiateViewControllerWithIdentifier("Symbols1Keyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRectMake(0, 0, AppDelegate.instance().window!.screen.bounds.width, height)
            _symbols1!.view!.frame = size
            _symbols1!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _symbols1!.view!
    }
    
    static var symbols2Keyboard : UIView {
        if _symbols2 == nil {
            _symbols2 = AppDelegate.instance().storyboard!.instantiateViewControllerWithIdentifier("Symbols2Keyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRectMake(0, 0, AppDelegate.instance().window!.screen.bounds.width, height)
            _symbols2!.view!.frame = size
            _symbols2!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _symbols2!.view!
    }
    
    static var basicNumbersKeyboard : UIView {
        if _basicNumbers == nil {
            _basicNumbers = AppDelegate.instance().storyboard!.instantiateViewControllerWithIdentifier("NumbersKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRectMake(0, 0, AppDelegate.instance().window!.screen.bounds.width, height)
            _basicNumbers!.view!.frame = size
            _basicNumbers!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basicNumbers!.view!
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.view ~> UIButton.self).each {
            $0.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
            $0.addTarget(self, action: #selector(BasicKeyboardController.cancelTimer(_:)), forControlEvents: .TouchUpInside)
            $0.addTarget(self, action: #selector(BasicKeyboardController.cancelTimer(_:)), forControlEvents: .TouchUpOutside)
            $0.addTarget(self, action: #selector(BasicKeyboardController.didTapButton(_:)), forControlEvents: .TouchDown)
            $0.exclusiveTouch = true
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BasicKeyboardController.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func keyboardWillChange(notification: NSNotification) {
        
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        BasicKeyboardController.keyboardHeight = keyboardFrame.size.height
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let keyboardContainer = self.parentViewController {
            (keyboardContainer.view ~> UIView.self).each{$0.hidden = true}
        }
        self.goLowercase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        super.textWillChange(textInput)
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        super.textDidChange(textInput)
        // The app has just changed the document's contents, the document context has been updated.
    
    }
    
    static var keyboardSwitch: ((UIView) -> Void)? = nil
    var repeatTimer: NSTimer? = nil
    
    @IBAction func cancelTimer(sender: UIButton) {
        self.repeatTimer?.invalidate()
        
        /*
        if sender.tag != 2 {
            let proxy = self.textDocumentProxy as UITextDocumentProxy
            if proxy.hasText() {
                self.repeatTitle = self.repeatTitle.lowercaseString
                self.goLowercase()
            }
            else {
                self.repeatTitle = self.repeatTitle.uppercaseString
                self.goUppercase()
            }
        }
        */
    }
    
    func repeatText() {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.insertText(repeatTitle)
        self.repeatTimer?.invalidate()
        self.repeatTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(BasicKeyboardController.repeatText), userInfo: nil, repeats: false)
    }
    
    func repeatDelete() {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.deleteBackward()
        self.repeatTimer?.invalidate()
        self.repeatTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(BasicKeyboardController.repeatDelete), userInfo: nil, repeats: false)
    }

    var repeatTitle = ""
    
    func goUppercase() {
        (self.view ~> UIButton.self).each {
            if $0.tag == 0 {
                let title = $0.titleForState(.Normal)
                $0.setTitle(title?.uppercaseString, forState: .Normal)
            }
        }
        self.lowercase = false
    }
    
    func goLowercase() {
        (self.view ~> UIButton.self).each {
            if $0.tag == 0 {
                let title = $0.titleForState(.Normal)
                $0.setTitle(title?.lowercaseString, forState: .Normal)
            }
        }
        self.lowercase = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let keyboardContainer = self.parentViewController {
            (keyboardContainer.view ~> UIView.self).each{$0.hidden = true}
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let keyboardContainer = self.parentViewController {
            (keyboardContainer.view ~> UIView.self).each{$0.hidden = false}
        }
    }

    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        if parent != nil {
            (parent!.view ~> UIView.self).each {$0.hidden = true}
        }
    }
    
    @IBAction func didTapButton(sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        self.repeatTimer?.invalidate()
        
        if let title = sender.titleForState(.Normal) {
            switch sender.tag {
            case 6 :
                proxy.deleteBackward()
                self.repeatTitle = ""
                self.repeatTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(BasicKeyboardController.repeatDelete), userInfo: nil, repeats: false)
            case 7 :
                BasicKeyboardController.keyboardSwitch?(BasicKeyboardController.symbols1Keyboard)
            case 8 :
                BasicKeyboardController.keyboardSwitch?(BasicKeyboardController.basicKeyboard)
            case 9 :
                BasicKeyboardController.keyboardSwitch?(BasicKeyboardController.symbols2Keyboard)
            case 5 :
                proxy.insertText("\n")
            case 2 :
                // toggle case for all keys
                if self.lowercase {
                    self.goUppercase()
                }
                else {
                    self.goLowercase()
                }
            case 3 :
                proxy.insertText(" ")
                self.repeatTitle = " "
                self.repeatTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(BasicKeyboardController.repeatText), userInfo: nil, repeats: false)
            //case "CHG" :
            //    self.advanceToNextInputMode()
            default :
                proxy.insertText(title)
                self.repeatTitle = title
                self.repeatTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(BasicKeyboardController.repeatText), userInfo: nil, repeats: false)

            }
        }
        
        // TODO: capitalize based on proxy.autocapitalizationType
        if sender.tag != 2 {
            self.goLowercase()
            self.repeatTitle = self.repeatTitle.lowercaseString
        }
        /*
            if proxy.hasText() {
                self.repeatTitle = self.repeatTitle.lowercaseString
                self.goLowercase()
            }
            else {
                self.repeatTitle = self.repeatTitle.uppercaseString
                self.goUppercase()
            }
        }
        */
    }
}
