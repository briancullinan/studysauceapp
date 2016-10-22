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
    var timer: Timer? = nil
    var isAudio = false
    var isImage = false
    weak var parentVC: UIViewController? = nil
    
    var autoPlay = true
    var shouldPlay = false

    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var size: NSLayoutConstraint!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet internal weak var prompt: UITextView!
    @IBOutlet internal weak var listenButton: UIButton!
    @IBOutlet internal weak var playButton: DALabeledCircularProgressView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prompt.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.alignPlay(self.prompt)        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.prompt.removeObserver(self, forKeyPath: "contentSize")
    }
    
    /// Force the text in a UITextView to always center itself.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.alignPlay(self.prompt)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.alignPlay(self.prompt)
    }
    
    internal func alignPlay(_ v: UITextView) {
        self.view.layoutIfNeeded()
        
        let content = v.attributedText.string as NSString
        let wholeRange = NSMakeRange(0, content.length)
        let range = content.range(of: "P14y", options: [], range: wholeRange)
        
        var topCorrect = (v.bounds.size.height - v.contentSize.height * v.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        v.contentInset.top = topCorrect
        
        if range.length > 0 {
            let start = v.position(from: v.beginningOfDocument, offset: range.location)!
            // text position of the end of the range
            let end = v.position(from: start, offset: range.length)!
            
            // text range of the range
            let tRange = v.textRange(from: start, to: end)
            let position = v.firstRect(for: tRange!)

            let global = self.view.convert(position, from: v)
            self.size.constant = global.height
            self.top.constant = global.origin.y + ((global.height - self.size.constant) / 2)
            self.left.constant = global.origin.x + ((global.width - self.size.constant) / 2)
            if self.isAudio {
                self.listenButton.isHidden = false
                self.playButton.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.prompt != nil {
            self.prompt!.text = self.card!.content!
            
            self.setupContent(self.prompt!)
            
            self.playButton.isHidden = true
            self.listenButton.isHidden = true
            self.image.isHidden = true
            self.showButtonsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CardPromptController.updatePlay), userInfo: nil, repeats: true)
            self.autoPlay = !(self is CardResponseController)
            self.view.sendSubview(toBack: self.image)
            if let banner = (self.view ~> (UIView.self ~* 34173)).first {
                self.view.sendSubview(toBack: banner)
            }
        }
    }
    
    internal func setupContent(_ view: UITextView) {
        var content = view.text as NSString
        
        // replace new line characters with real lines
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpression.Options.caseInsensitive)
        content = lines!.stringByReplacingMatches(in: String(content), options: [], range: NSMakeRange(0, content.length), withTemplate: "\n") as NSString
        
        // find the hyperlink and replace it with a listen button
        let ex = try? NSRegularExpression(pattern: "https://.*", options: NSRegularExpression.Options.caseInsensitive)
        let match = ex!.firstMatch(in: String(content), options: [], range:NSMakeRange(0, content.length))
        let matched = match?.rangeAt(0)
        if matched != nil {
            self.url = content.substring(with: matched!).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            content = ex!.stringByReplacingMatches(in: String(content), options: [], range: matched!, withTemplate: "P14y") as NSString
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
            if let pvc = self.parentVC as? CardBlankController {
                let wordCount = try? NSRegularExpression(pattern: "^(\\b\\w+\\b[\\s\\r\\n!\"#$%&'()*+, \\-./:;<=>?@ [\\\\]^_`{|}~]*){1,15}$", options: [.caseInsensitive])
                let wordCountMatch = wordCount?.firstMatch(in: String(content), options: [], range: NSMakeRange(0, content.length))
                if wordCountMatch?.rangeAt(0) != nil {
                    pvc.inputText?.placeholder = content.replacingOccurrences(of: "P14y", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
        self.prompt.text = String(content)
    }
    
    var showButtonsTimer: Timer? = nil
    
    func updatePlay() {
        self.alignPlay(self.prompt)
        if self.url != nil {
            if ((AppDelegate.visibleViewController() == self.parentVC && self.parentVC is CardController) || (AppDelegate.visibleViewController() == self.parentVC?.parent && self.parentVC?.parent is CardController)) && !CardSegue.transitionManager.transitioning {
                self.shouldPlay = self.autoPlay
                self.downloadAudio(self.url!)
                showButtonsTimer?.invalidate()
            }
        }
    }
    
    func downloadAudio(_ url: String) {
        if self.playing {
            return
        }
        self.playing = true
        // temporarily turn off playing while downloading
        File.save(url, done: {(f:File) in
            let fileName = f.filename!
            let url = URL(fileURLWithPath: fileName)
            // check what type of media file we need to display
            if self.isAudio {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                self.listenButton.alpha = 1
                self.view.bringSubview(toFront: self.listenButton)
                
                if self.player == nil {
                    self.player = try? AVAudioPlayer(contentsOf: url)
                    self.player?.delegate = self
                    self.player?.prepareToPlay()
                }
                
                if self.shouldPlay {
                    self.player?.play()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(CardPromptController.updateProgress), userInfo: nil, repeats: true)
                    self.shouldPlay = false
                }
                else {
                    self.playing = false
                }
            }
            else if self.isImage {
                self.listenButton.isHidden = true
                self.playButton.isHidden = true
                self.image.isHidden = false
                if fileName == "notfound" {
                    self.image.image = UIImage(named: "notfound")
                }
                else {
                    self.image.image = UIImage(contentsOfFile: fileName)
                }
                self.view.sendSubview(toBack: self.image)
                if let banner = (self.view ~> (UIView.self ~* 34173)).first {
                    self.view.sendSubview(toBack: banner)
                }
            }
        })
    }
    
    func updateProgress() {
        if self.player != nil {
            self.playButton.setProgress(CGFloat(self.player!.currentTime) / CGFloat(self.player!.duration), animated: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playing = false
        self.listenButton.alpha = 0.5
        self.timer?.invalidate()
        self.timer = nil
        self.playButton.setProgress(0, animated: false)
    }

    @IBAction func listenClick(_ sender: UIButton) {
        
        if (self.url != nil) {
            self.shouldPlay = true
            self.downloadAudio(self.url!)
        }
    }
}
