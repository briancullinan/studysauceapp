//
//  CardResponseController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class CardResponseController : CardPromptController {
    
    @IBOutlet weak var response: UITextView!
    @IBOutlet weak var promptHeight: NSLayoutConstraint!
    @IBOutlet weak var nextLabel: UILabel!
    
    override func alignPlay(_ v: UITextView) {
        
        if self.isImage || self.isAudio {
            self.promptHeight.constant = self.view.bounds.height * 0.4
        }
        else {
            self.promptHeight.constant = min(self.prompt!.contentSize.height + saucyTheme.padding * 5, self.view.bounds.height * 0.45)
        }
        
        var topCorrect = (self.response.bounds.size.height - self.response.contentSize.height * self.response.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.response.contentInset.top = topCorrect

        super.alignPlay(v)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.parent is CardSelfController {
            self.nextLabel.isHidden = true
        }
        
        self.response.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.response.removeObserver(self, forKeyPath: "contentSize")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var response = ""
        
        let correct = self.card!.getCorrect()
        if correct == nil || correct!.value == nil {
            if self.card!.response != nil && self.card!.response != "" {
                response = "\(self.card!.response!)"
            }
        }
        else {
            if self.card!.response != nil && self.card!.response != "" {
                response = "\(correct!.content!)\n\r\(self.card!.response!)"
            }
            else {
                response = "\(correct!.content!)"
            }
        }
        
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpression.Options.caseInsensitive)
        response = lines!.stringByReplacingMatches(in: response, options: [], range: NSMakeRange(0, response.characters.count), withTemplate: "\n")
        
        self.response!.text = response
    }
}
