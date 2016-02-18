//
//  File.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/17/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData


class File: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    var downloading = false
    
    static func save(var url: String, done: (_: File) -> Void = {(_: File) in}) {
        let fileManager = NSFileManager.defaultManager()
        url = url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        AppDelegate.performContext({
            let file = AppDelegate.list(File.self).filter({$0.url! == url}).first ?? AppDelegate.insert(File.self) <| {
                $0.url = url
            }
            AppDelegate.saveContext()

            if file.filename != nil && fileManager.fileExistsAtPath(file.filename!) {
                doMain {
                    done(file)
                }
                return
            }
            if file.downloading {
                return
            }
            file.downloading = true
            doBackground {
                let data = NSData(contentsOfURL: NSURL(string: url)!)!
                let fileName = fileManager.displayNameAtPath(url)
                let tempFile = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent(fileName)
                fileManager.createFileAtPath(tempFile.path!, contents: data, attributes: nil)
                AppDelegate.performContext({
                    file.filename = tempFile.path
                    AppDelegate.saveContext()
                    file.downloading = false
                    // show image
                    doMain {
                        done(file)
                    }
                })
            }
        })
        
    }
    
}
