//
//  UIViewController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController {
    
    func showDialog(message: String?, button: String?) {
        self.showDialog(message, button: button, done: {
            return true
        })
    }
    
    func postJson (url: String, params: Dictionary<String, AnyObject?>, done: () -> Void = {(code) in}, error: (code: Int) -> Void = {(code) in}, redirect: (path: String) -> Void = {(path) in}){
        var postData = ""
        for (k, v) in params {
            postData = postData + (postData == "" ? "&" : "") + k.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())! + "=" + v!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        }
        let data = postData.dataUsingEncoding(NSUTF8StringEncoding)
        let request = NSMutableURLRequest(URL: AppDelegate.studySauceCom(url))
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        request.setValue(String(data!.length), forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithRequest(request, completionHandler: {data, response, err -> Void in
            if (err != nil) {
                NSLog("\(err?.description)")
            }
            if (response as? NSHTTPURLResponse)?.statusCode != 200 {
                error(code: (response as! NSHTTPURLResponse).statusCode)
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                dispatch_async(dispatch_get_main_queue(), {
                    // change this if we want to register without a code
                    if json["redirect"] as? String != nil {
                        redirect(path: json["redirect"] as! String)
                    }
                    done()
                })
            }
            catch let error as NSError {
                NSLog("\(error.description)")
            }
        })
        task.resume()

    }
    
    func showDialog(message: String?, button: String?, done: () -> Bool) -> DialogController {
        let dialog = self.storyboard!.instantiateViewControllerWithIdentifier("Dialog") as! DialogController
        dialog.message = message
        dialog.button = button
        dialog.click = done
        dialog.modalPresentationStyle = .OverCurrentContext
        dispatch_async(dispatch_get_main_queue(),{
            self.presentViewController(dialog, animated: true, completion: {
            
            })
        })
        return dialog
    }
    
    func showNoConnectionDialog(done: () -> Void) {
        if AppDelegate.isConnectedToNetwork() {
            done()
        }
        else {
            var timer: NSTimer? = nil
            let dialog = self.showDialog("No internet connection".localized, button: "Try again".localized, done: {
                let result = AppDelegate.isConnectedToNetwork()
                if result {
                    timer?.invalidate()
                    done()
                }
                return result
            })
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: dialog, selector: Selector("done"), userInfo: nil, repeats: true)
        }
    }
}