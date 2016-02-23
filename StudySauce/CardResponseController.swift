//
//  CardResponseController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class CardResponseController : UIViewController {
    weak var card: Card!
    
    @IBOutlet weak var response: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.response.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.response.removeObserver(self, forKeyPath: "contentSize")
    }
    
    /// Force the text in a UITextView to always center itself.
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let correct = self.card.getCorrect()
        if correct == nil || correct!.value == nil {
            self.response!.text = "\(self.card.response!)"
        }
        else {
            if self.card.response != nil && self.card.response != "" {
                self.response!.text = "\(correct!.content!)\n\r\(self.card.response!)"
            }
            else {
                self.response!.text = "\(correct!.content!)"
            }
        }
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpressionOptions.CaseInsensitive)
        self.response.text = lines!.stringByReplacingMatchesInString(self.response.text!, options: [], range: NSMakeRange(0, self.response.text!.characters.count), withTemplate: "\n")
    }
    
}