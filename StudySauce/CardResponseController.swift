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
    
    override func alignPlay(v: UITextView) {
        
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
    
    override func viewWillAppear(animated: Bool) {
        if self.parentViewController is CardSelfController {
            self.nextLabel.hidden = true
        }
        
        self.response.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.response.removeObserver(self, forKeyPath: "contentSize")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let correct = self.card!.getCorrect()
        if correct == nil || correct!.value == nil {
            self.response!.text = "\(self.card!.response!)"
        }
        else {
            if self.card!.response != nil && self.card!.response != "" {
                self.response!.text = "\(correct!.content!)\n\r\(self.card!.response!)"
            }
            else {
                self.response!.text = "\(correct!.content!)"
            }
        }
    }
}