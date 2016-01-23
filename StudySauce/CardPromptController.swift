//
//  CardPromptController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import AVFoundation
import QuartzCore

class CardPromptController: UIViewController, AVAudioPlayerDelegate, UIScrollViewDelegate {
    weak var card: Card? = nil
    var player: AVAudioPlayer? = nil
    var url: String? = nil
    var playing: Bool = false
    var timer: NSTimer? = nil
    var shouldPlay = false

    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var size: NSLayoutConstraint!
    
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var playButton: DALabeledCircularProgressView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.content.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.content.removeObserver(self, forKeyPath: "contentSize")
    }
    
    /// Force the text in a UITextView to always center itself.
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        doMain(self.updateListenPosition)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateListenPosition()
    }
    
    func setAttributedText() {
        // align listen button to substring
        let content = self.content!.attributedText.string as NSString
        let wholeRange = NSMakeRange(0, content.length)
        let range = content.rangeOfString("P14y", options: [], range: wholeRange)
        
        if range.length > 0 {
            let attr = NSMutableAttributedString(attributedString: self.content.attributedText)
            attr.addAttribute(NSFontAttributeName, value: UIFont(name: self.content!.font!.fontName, size: 50.0 * saucyTheme.multiplier())!, range: range)
            attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.clearColor(), range: range)
            self.content.attributedText = NSAttributedString(attributedString: attr)
        }
    }
    
    
    var showButtons: NSDate? = nil
    var showButtonsTimer: NSTimer? = nil
    func updateListenPosition() {
        if self.url != nil && self.showButtons != nil && NSDate() > self.showButtons! {
            self.showButtonsTimer?.invalidate()
            //self.content.attributedText = self.getAttributedText(self.content.text)
            let text = self.content.attributedText.string as NSString
            let wholeRange = NSMakeRange(0, self.content.attributedText.length)
            let range = text.rangeOfString("P14y", options: [], range: wholeRange)
            
            let start = self.content.positionFromPosition(self.content.beginningOfDocument, offset: range.location)!
            // text position of the end of the range
            let end = self.content.positionFromPosition(start, offset: range.length)!
            
            // text range of the range
            let tRange = self.content.textRangeFromPosition(start, toPosition: end)
            let position = self.content.firstRectForRange(tRange!)
            let global = self.view.convertRect(position, fromView: self.content)
            
            doMain {
                self.size.constant = global.height
                self.top.constant = global.origin.y + ((global.height - self.size.constant) / 2)
                self.left.constant = global.origin.x + ((global.width - self.size.constant) / 2)
                self.listenButton.hidden = false
                self.playButton.hidden = false
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateListenPosition()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var content = self.card!.content
        
        // replace new line characters with real lines
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpressionOptions.CaseInsensitive)
        content = lines?.stringByReplacingMatchesInString(content!, options: [], range: NSMakeRange(0, content!.characters.count), withTemplate: "\n")

        
        // find the hyperlink and replace it with a listen button
        let ex = try? NSRegularExpression(pattern: "https://.*", options: NSRegularExpressionOptions.CaseInsensitive)
        let match = ex?.firstMatchInString(content!, options: [], range:NSMakeRange(0, content!.characters.count))
        let matched = match?.rangeAtIndex(0)
        if matched != nil {
            let range = Range(
                start: self.card!.content!.startIndex.advancedBy(matched!.location),
                end:   self.card!.content!.startIndex.advancedBy(matched!.location + matched!.length))
            self.url = self.card!.content!.substringWithRange(range)
            content!.replaceRange(range, with: "P14y")
            self.downloadAudio(self.url!)
        }
        self.content.text = content
        self.setAttributedText()
        self.showButtons = NSDate().dateByAddingTimeInterval(1)
        self.showButtonsTimer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self, selector: "updateListenPosition", userInfo: nil, repeats: true)
    }
    
    func downloadAudio(url: String) {
        if self.playing {
            return
        }
        self.playing = true
        self.listenButton.alpha = 1
        File.save(url, done: {(f:File) in
            let fileName = f.filename!
            let url = NSURL(fileURLWithPath: fileName)
            // check what type of media file we need to display
            if (fileName.hasSuffix(".m4a") || fileName.hasSuffix(".mp3")) {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                self.view.bringSubviewToFront(self.listenButton)
                
                if self.player == nil {
                    self.player = try? AVAudioPlayer(contentsOfURL: url)
                    self.player?.delegate = self
                    self.player?.prepareToPlay()
                }
                if self.shouldPlay {
                    self.player!.play()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
                }
                else {
                    self.playing = false
                }
            }
            else if(fileName.hasSuffix(".jpg") || fileName.hasSuffix(".jpeg") || fileName.hasSuffix(".gif") || fileName.hasSuffix(".png")) {
                self.listenButton.setBackgroundImage(UIImage(contentsOfFile: fileName), forState: .Normal)
                self.playButton.hidden = true
            }
        })
    }
    
    func updateProgress() {
        self.playButton.setProgress(CGFloat(self.player!.currentTime) / CGFloat(self.player!.duration), animated: false)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.playing = false
        self.listenButton.alpha = 0.5
        self.timer?.invalidate()
        self.timer = nil
        self.playButton.setProgress(0, animated: false)
    }

    @IBAction func listenClick(sender: UIButton) {
        
        if (self.url != nil) {
            self.shouldPlay = true
            self.downloadAudio(self.url!)
        }
    }
}