//
//  JSON.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/19/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

func getJson (_ url: String,
              _ params: Dictionary<String, AnyObject?> = Dictionary(),
              error: @escaping (_ code: Int) -> Void = {(code) in},
              redirect: @escaping (_ path: String) -> Void = {(path) in},
              _ done: @escaping (_ json: AnyObject) -> Void = {(json) in}) {
    var postData = ""
    for (k, v) in params {
        postData += (postData == "" ? "" : "&") + stringify("\(k)", v)
    }
    let absolute = AppDelegate.studySauceCom("\(url)?\(postData)")
    let request = NSMutableURLRequest(url: absolute!)
    //NSLog("Downloading from \(absolute.absoluteString)")
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    let ses = URLSession.shared
    let task = ses.dataTask(with: request as URLRequest) {data, response, err in
        AppDelegate.performContext {
            let cookies = HTTPCookieStorage.shared.cookies?.getJSON()
            UserLoginController.filterDomain(AppDelegate.list(User.self)).each {$0.setProperty("session", cookies as AnyObject)}
            AppDelegate.saveContext()
        }
        var hadError = false
        if (err != nil) {
            hadError = true
            NSLog("\(err!)")
        }
        if response as? HTTPURLResponse != nil && (response as? HTTPURLResponse)?.statusCode != 200 {
            hadError = true
            error((response as! HTTPURLResponse).statusCode)
        }
        if data != nil {
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.allowFragments])
                doMain {
                    // change this if we want to register without a code
                    if (json as? [String:Any])?["redirect"] as? String != nil {
                        redirect((json as? [String:Any])?["redirect"] as! String)
                    }
                    if !hadError {
                        done(json as AnyObject)
                    }
                }
            }
            catch let e as NSError {
                NSLog("\(e.description)")
                error((response as! HTTPURLResponse).statusCode)
            }
        }
    }
    task.resume()
}

private func stringify(_ key: String, _ val: AnyObject?) -> String {
    var result = ""
    if val is NSArray {
        var count = 0
        for v in val as! NSArray {
            result += (result == "" ? "" : "&") + stringify(key + "[\(count)]", v as AnyObject?)
            count += 1
        }
    }
    else if val is NSDictionary {
        for (k, v) in val as! NSDictionary {
            result += (result == "" ? "" : "&") + stringify(key + "[\(k)]", v as AnyObject?)
        }
    }
    else {
        let v = "\(val!)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        result += (result == "" ? "" : "&") + "\(key)=\(v)"
    }
    return result
}

func postJson (_ url: String,
               _ params: Dictionary<String, AnyObject?> = Dictionary(),
               error: @escaping (_ code: Int) -> Void = {(code) in},
               redirect: @escaping (_ path: String) -> Void = {(path) in},
               _ done: @escaping (_ json: AnyObject) -> Void = {(json) in}
    ){
    postJson(url, params, error: error, redirect: {(json: AnyObject) -> Void in
        if json["redirect"] as? String != nil {
            let url = URL(string: json["redirect"] as! String)
            redirect(url!.path)
        }
    }, done)
}

func postJson (_ url: String,
               _ params: Dictionary<String, AnyObject?> = Dictionary(),
               error: @escaping (_ code: Int) -> Void = {(code) in},
               redirect: @escaping (_ json: AnyObject) -> Void,
               _ done: @escaping (_ json: AnyObject) -> Void = {(json) in}
    ){
    var postData = ""
    for (k, v) in params {
        if v == nil {
            continue
        }
        postData = postData + (postData == "" ? "" : "&")  + stringify("\(k)", v)
    }
    let data = postData.data(using: String.Encoding.utf8)
    let request = NSMutableURLRequest(url: AppDelegate.studySauceCom(url))
    request.httpMethod = "POST"
    request.httpBody = data
    request.setValue(String(data!.count), forHTTPHeaderField: "Content-Length")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    let ses = URLSession.shared
    let task = ses.dataTask(with: request as URLRequest) {data, response, err in
        AppDelegate.performContext {
            let cookies = HTTPCookieStorage.shared.cookies?.getJSON()
            UserLoginController.filterDomain(AppDelegate.list(User.self)).each {$0.setProperty("session", cookies as AnyObject)}
            AppDelegate.saveContext()
        }
        var hadError = false
        if (err != nil) {
            hadError = true
            NSLog("\(err!)")
        }
        if response as? HTTPURLResponse != nil && (response as? HTTPURLResponse)?.statusCode != 200 {
            hadError = true
            error((response as! HTTPURLResponse).statusCode)
        }
        if data != nil {
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.allowFragments]) as! [String:Any]
                doMain {
                    // change this if we want to register without a code
                    if json["redirect"] as? String != nil {
                        redirect(json as AnyObject)
                    }
                    if !hadError {
                        done(json as AnyObject)
                    }
                }
            }
            catch let e as NSError {
                NSLog("\(e.description)")
                error((response as! HTTPURLResponse).statusCode)
            }
        }
    }
    task.resume()
}
