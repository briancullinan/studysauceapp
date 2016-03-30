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
    internal weak var card: Card? = nil
    var player: AVAudioPlayer? = nil
    var url: String? = nil
    var playing: Bool = false
    var timer: NSTimer? = nil
    var isAudio = false
    var isImage = false
    weak var parent: UIViewController? = nil
    
    var autoPlay = true
    var shouldPlay = false

    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var size: NSLayoutConstraint!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet internal weak var prompt: UITextView!
    @IBOutlet internal weak var listenButton: UIButton!
    @IBOutlet internal weak var playButton: DALabeledCircularProgressView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prompt.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.alignPlay(self.prompt)        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.prompt.removeObserver(self, forKeyPath: "contentSize")
    }
    
    /// Force the text in a UITextView to always center itself.
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.alignPlay(self.prompt)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.alignPlay(self.prompt)
    }
    
    internal func alignPlay(v: UITextView) {
        self.view.layoutIfNeeded()
        
        let content = v.attributedText.string as NSString
        let wholeRange = NSMakeRange(0, content.length)
        let range = content.rangeOfString("P14y", options: [], range: wholeRange)
        
        var topCorrect = (v.bounds.size.height - v.contentSize.height * v.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        v.contentInset.top = topCorrect
        
        if range.length > 0 {
            let start = v.positionFromPosition(v.beginningOfDocument, offset: range.location)!
            // text position of the end of the range
            let end = v.positionFromPosition(start, offset: range.length)!
            
            // text range of the range
            let tRange = v.textRangeFromPosition(start, toPosition: end)
            let position = v.firstRectForRange(tRange!)

            let global = self.view.convertRect(position, fromView: v)
            self.size.constant = global.height
            self.top.constant = global.origin.y + ((global.height - self.size.constant) / 2)
            self.left.constant = global.origin.x + ((global.width - self.size.constant) / 2)
            if self.isAudio {
                self.listenButton.hidden = false
                self.playButton.hidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.prompt != nil {
            self.prompt!.text = self.card!.content!
            
            self.setupContent(self.prompt!)
            
            self.playButton.hidden = true
            self.listenButton.hidden = true
            self.image.hidden = true
            self.showButtonsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(CardPromptController.updatePlay), userInfo: nil, repeats: true)
            self.autoPlay = !(self is CardResponseController)
            self.view.sendSubviewToBack(self.image)
            if let banner = (self.view ~> (UIView.self ~* 34173)).first {
                self.view.sendSubviewToBack(banner)
            }
        }
    }
    
    internal func setupContent(view: UITextView) {
        var content = view.text
        
        // replace new line characters with real lines
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpressionOptions.CaseInsensitive)
        content = lines!.stringByReplacingMatchesInString(content, options: [], range: NSMakeRange(0, content.characters.count), withTemplate: "\n")
        
        // find the hyperlink and replace it with a listen button
        let ex = try? NSRegularExpression(pattern: "https://.*", options: NSRegularExpressionOptions.CaseInsensitive)
        let match = ex?.firstMatchInString(content, options: [], range:NSMakeRange(0, content.characters.count))
        let matched = match?.rangeAtIndex(0)
        if matched != nil {
            let range = content.startIndex.advancedBy(matched!.location)...content.startIndex.advancedBy(matched!.location + matched!.length)
            self.url = content.substringWithRange(range).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            content.replaceRange(range, with: "P14y")
            if (self.url!.hasSuffix(".m4a") || self.url!.hasSuffix(".mp3")) {
                self.isAudio = true
                self.isImage = false
            }
            else if self.url!.hasSuffix(".jpg") || self.url!.hasSuffix(".jpeg") || self.url!.hasSuffix(".gif") || self.url!.hasSuffix(".png") {
                self.isImage = true
                self.isAudio = false
            }
            self.downloadAudio(self.url!)
            
            // use remaining text as fill in the blank placeholder
            if let pvc = self.parent as? CardBlankController {
                let wordCount = try? NSRegularExpression(pattern: "^(\\b\\w+\\b[\\s\\r\\n!\"#$%&'()*+, \\-./:;<=>?@ [\\\\]^_`{|}~]*){1,15}$", options: [.CaseInsensitive])
                let wordCountMatch = wordCount?.firstMatchInString(content, options: [], range: NSMakeRange(0, content.characters.count))
                if wordCountMatch?.rangeAtIndex(0) != nil {
                    pvc.inputText?.placeholder = content.stringByReplacingOccurrencesOfString("P14y", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    content = "P14y"
                }
                if self.isImage {
                    pvc.bottomHalf.constant = 0
                }
                else {
                    pvc.bottomHalf.constant = pvc.view.bounds.height * 1/2
                }
                pvc.view.layoutIfNeeded()
            }
        }
        self.prompt.text = content
    }
    
    var showButtonsTimer: NSTimer? = nil
    
    func updatePlay() {
        self.alignPlay(self.prompt)
        if self.url != nil {
            if ((AppDelegate.visibleViewController() == self.parentViewController && self.parentViewController is CardController) || (AppDelegate.visibleViewController() == self.parentViewController?.parentViewController && self.parentViewController?.parentViewController is CardController)) && !CardSegue.transitionManager.transitioning {
                self.shouldPlay = self.autoPlay
                self.downloadAudio(self.url!)
                showButtonsTimer?.invalidate()
            }
        }
    }
    
    func downloadAudio(url: String) {
        if self.playing {
            return
        }
        self.playing = true
        // temporarily turn off playing while downloading
        File.save(url, done: {(f:File) in
            let fileName = f.filename!
            let url = NSURL(fileURLWithPath: fileName)
            // check what type of media file we need to display
            if self.isAudio {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                self.listenButton.alpha = 1
                self.view.bringSubviewToFront(self.listenButton)
                
                if self.player == nil {
                    self.player = try? AVAudioPlayer(contentsOfURL: url)
                    self.player?.delegate = self
                    self.player?.prepareToPlay()
                }
                
                if self.shouldPlay {
                    self.player!.play()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: #selector(CardPromptController.updateProgress), userInfo: nil, repeats: true)
                    self.shouldPlay = false
                }
                else {
                    self.playing = false
                }
            }
            else if self.isImage {
                self.listenButton.hidden = true
                self.playButton.hidden = true
                self.image.hidden = false
                if fileName == "notfound" {
                    self.image.image = UIImage(named: "notfound")
                }
                else {
                    self.image.image = UIImage(contentsOfFile: fileName)
                }
                self.view.sendSubviewToBack(self.image)
                if let banner = (self.view ~> (UIView.self ~* 34173)).first {
                    self.view.sendSubviewToBack(banner)
                }
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