//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Tope Abayomi on 19/09/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import UIKit

class BasicKeyboardController: UIInputViewController {

    var lowercase = false
    
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
        
        doMain {
            (self.view ~> UIButton.self).each {
                if $0.tag == 0 {
                    let title = $0.titleForState(.Normal)
                    $0.setTitle(title?.lowercaseString, forState: .Normal)
                }
            }
            self.lowercase = true
        }
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
    
    @IBAction func didTapButton(sender: UIButton, forEvent event: UIEvent) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        if let title = sender.titleForState(.Normal) {
            switch sender.tag {
            case 6 :
                proxy.deleteBackward()
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
                    (self.view ~> UIButton.self).each {
                        if $0.tag == 0 {
                            let title = $0.titleForState(.Normal)
                            $0.setTitle(title?.uppercaseString, forState: .Normal)
                        }
                    }
                    self.lowercase = false
                }
                else {
                    (self.view ~> UIButton.self).each {
                        if $0.tag == 0 {
                            let title = $0.titleForState(.Normal)
                            $0.setTitle(title?.lowercaseString, forState: .Normal)
                        }
                    }
                    self.lowercase = true
                }
            case 3 :
                proxy.insertText(" ")
            //case "CHG" :
            //    self.advanceToNextInputMode()
            default :
                proxy.insertText(title)
            }
        }
    }
    
}
