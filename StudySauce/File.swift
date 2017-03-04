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
    
    static func save(_ url: String, done: @escaping (_: File) -> Void = {(_: File) in}) {
        let fileManager = FileManager.default
        let urlTrimmed = url.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        AppDelegate.performContext({
            var file = AppDelegate.list(File.self).filter({$0.url == urlTrimmed}).first
            if file == nil {
                file = AppDelegate.insert(File.self) <| {
                    $0.url = urlTrimmed
                }
            }
            AppDelegate.saveContext()

            if file!.filename != nil && fileManager.fileExists(atPath: file!.filename!) {
                doMain {
                    done(file!)
                }
                return
            }
            if file!.downloading {
                return
            }
            file!.downloading = true
            doBackground {
                let data = try? Data(contentsOf: URL(string: urlTrimmed)!)
                let fileName = fileManager.displayName(atPath: urlTrimmed)
                let tempFile = AppDelegate.applicationDocumentsDirectory.appendingPathComponent(fileName)
                if data == nil {
                    AppDelegate.performContext({
                        file!.filename = "notfound"
                        AppDelegate.saveContext()
                        file!.downloading = false
                        // show image
                        doMain {
                            done(file!)
                        }
                    })
                    return
                }
                fileManager.createFile(atPath: tempFile.path, contents: data!, attributes: nil)
                AppDelegate.performContext({
                    file!.filename = tempFile.path
                    AppDelegate.saveContext()
                    file!.downloading = false
                    // show image
                    doMain {
                        done(file!)
                    }
                })
            }
        })
        
    }
    
}
