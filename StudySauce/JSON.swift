//
//  JSON.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/19/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

func getJson (url: String, params: Dictionary<String, AnyObject?> = Dictionary(), done: ((json: AnyObject?) -> Void)? = nil, error: ((code: Int) -> Void)? = nil, redirect: ((path: String) -> Void)? = nil) {
    var postData = ""
    for (k, v) in params {
        postData = postData + (postData == "" ? "" : "&") + k.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())! + "=" + (v == nil
            ? ""
            : v!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)
    }
    let request = NSMutableURLRequest(URL: AppDelegate.studySauceCom("\(url)?\(postData)"))
    request.HTTPMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    let ses = NSURLSession.sharedSession()
    let task = ses.dataTaskWithRequest(request, completionHandler: {data, response, err -> Void in
        var hadError = false
        if (err != nil) {
            hadError = true
            NSLog("\(err?.description)")
        }
        if error != nil && response as? NSHTTPURLResponse != nil && (response as? NSHTTPURLResponse)?.statusCode != 200 {
            hadError = true
            error!(code: (response as! NSHTTPURLResponse).statusCode)
        }
        if data != nil {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments])
                dispatch_async(dispatch_get_main_queue(), {
                    // change this if we want to register without a code
                    if redirect != nil && json["redirect"] as? String != nil {
                        redirect!(path: json["redirect"] as! String)
                    }
                    if !hadError && done != nil {
                        done!(json: json)
                    }
                })
            }
            catch let error as NSError {
                NSLog("\(error.description)")
            }
        }
    })
    task.resume()
}

func postJson (url: String, params: Dictionary<String, AnyObject?> = Dictionary(), done: (json: AnyObject?) -> Void = {(json) in}, error: (code: Int) -> Void = {(code) in}, redirect: (path: String) -> Void = {(path) in}){
    var postData = ""
    for (k, v) in params {
        postData = postData + (postData == "" ? "" : "&") + k.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())! + "=" + (v == nil
            ? ""
            : v!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)
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
        if response as? NSHTTPURLResponse != nil && (response as? NSHTTPURLResponse)?.statusCode != 200 {
            error(code: (response as! NSHTTPURLResponse).statusCode)
        }
        if data != nil {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments])
                dispatch_async(dispatch_get_main_queue(), {
                    // change this if we want to register without a code
                    if json["redirect"] as? String != nil {
                        redirect(path: json["redirect"] as! String)
                    }
                    done(json: json)
                })
            }
            catch let error as NSError {
                NSLog("\(error.description)")
            }
        }
        else {
            done(json: nil)
        }
    })
    task.resume()
    
}