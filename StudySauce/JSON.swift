//
//  JSON.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/19/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

func getJson (url: String, _ params: Dictionary<String, AnyObject?> = Dictionary(), error: (code: Int) -> Void = {(code) in}, redirect: (path: String) -> Void = {(path) in}, _ done: (json: AnyObject) -> Void = {(json) in}) {
    var postData = ""
    for (k, v) in params {
        postData += (postData == "" ? "" : "&") + stringify("\(k)", v)
    }
    let absolute = AppDelegate.studySauceCom("\(url)?\(postData)")
    let request = NSMutableURLRequest(URL: absolute)
    //NSLog("Downloading from \(absolute.absoluteString)")
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
                doMain {
                    // change this if we want to register without a code
                    if json["redirect"] as? String != nil {
                        redirect(path: json["redirect"] as! String)
                    }
                    if !hadError {
                        done(json: json)
                    }
                }
            }
            catch let e as NSError {
                NSLog("\(e.description)")
                error(code: (response as! NSHTTPURLResponse).statusCode)
            }
        }
    })
    task.resume()
}

private func stringify(key: String, _ val: AnyObject?) -> String {
    var result = ""
    if val is NSArray {
        var count = 0
        for v in val as! NSArray {
            result += (result == "" ? "" : "&") + stringify(key + "[\(count)]", v)
            count += 1
        }
    }
    else if val is NSDictionary {
        for (k, v) in val as! NSDictionary {
            result += (result == "" ? "" : "&") + stringify(key + "[\(k)]", v)
        }
    }
    else {
        let v = "\((val ?? "")!)".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        result += (result == "" ? "" : "&") + "\(key)=\(v)"
    }
    return result
}

func postJson (url: String, _ params: Dictionary<String, AnyObject?> = Dictionary(), error: (code: Int) -> Void = {(code) in}, redirect: (path: String) -> Void = {(path) in}, _ done: (json: AnyObject) -> Void = {(json) in}){
    postJson(url, params, error: error, redirect: {(json: AnyObject) in
        if json["redirect"] as? String != nil {
            let url = NSURL(string: json["redirect"] as! String)
            redirect(path: url!.path!)
        }
    }, done)
}

func postJson (url: String, _ params: Dictionary<String, AnyObject?> = Dictionary(), error: (code: Int) -> Void = {(code) in}, redirect: (json: AnyObject) -> Void, _ done: (json: AnyObject) -> Void = {(json) in}){
    var postData = ""
    for (k, v) in params {
        if v == nil {
            continue
        }
        postData = postData + (postData == "" ? "" : "&")  + stringify("\(k)", v)
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
                doMain {
                    // change this if we want to register without a code
                    if json["redirect"] as? String != nil {
                        redirect(json: json)
                    }
                    if !hadError {
                        done(json: json)
                    }
                }
            }
            catch let e as NSError {
                NSLog("\(e.description)")
                error(code: (response as! NSHTTPURLResponse).statusCode)
            }
        }
    })
    task.resume()
}