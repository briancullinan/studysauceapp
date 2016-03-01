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
    
    @IBOutlet weak var responseHeight: NSLayoutConstraint!
    
    override func alignPlay(v: UITextView) {
        super.alignPlay(v)
        
        var topCorrect = (self.response.bounds.size.height - self.response.contentSize.height * self.response.zoomScale) / 2 - saucyTheme.padding * 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.response.contentInset.top = topCorrect
        
        self.responseHeight.constant = min(self.response.contentSize.height + saucyTheme.padding * 4, self.view.bounds.height / 2)

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