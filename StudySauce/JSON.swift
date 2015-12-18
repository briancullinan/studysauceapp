//
//  JSON.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/19/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

func getJson (url: String, params: Dictionary<String, AnyObject?> = Dictionary(), done: (json: AnyObject?) -> Void = {(json) in}, error: (code: Int) -> Void = {(code) in}, redirect: (path: String) -> Void = {(path) in}) {
    var postData = ""
    for (k, v) in params {
        postData = postData + (postData == "" ? "" : "&") + "\(k)=\(v!)"
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
        if response as? NSHTTPURLResponse != nil && (response as? NSHTTPURLResponse)?.statusCode != 200 {
            hadError = true
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
                    if !hadError {
                        done(json: json)
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
        postData = postData + (postData == "" ? "" : "&") + "\(k)=\(v!)"
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
        var hadError = false
        if (err != nil) {
            hadError = true
            NSLog("\(err?.description)")
        }
        if response as? NSHTTPURLResponse != nil && (response as? NSHTTPURLResponse)?.statusCode != 200 {
            hadError = true
            error(code: (response as! NSHTTPURLResponse).statusCode)
        }
        if data != nil {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments])
                dispatch_async(dispatch_get_main_queue(), {
                    // change this if we want to register without a code
                    if json["redirect"] as? String != nil {
                        let url = NSURL(string: json["redirect"] as! String)
                        redirect(path: url!.path!)
                    }
                    if !hadError {
                        done(json: json)
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