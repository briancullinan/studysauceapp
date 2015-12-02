//
//  AppDelegate.swift
//  StudySauce
//
//  Created by admin on 9/12/15.
//  Copyright (c) 2015 The Study Institute. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {

    var window: UIWindow?
    var storyboard: UIStoryboard?
    var user: User? {
        didSet {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(user?.email, forKey: "user")
            userDefaults.synchronize() // don't forget this!!!!
        }
    }
    
    func visibleViewController() -> UIViewController {
        return self.visibleViewController(AppDelegate.instance().window!.rootViewController!)
    }
    
    func visibleViewController(rootViewController: UIViewController) -> UIViewController
    {
        let presentedViewController = rootViewController.presentedViewController;
        if rootViewController.presentedViewController == nil {
            return rootViewController
        }
        
        return self.visibleViewController(presentedViewController!);
    }
    
    static func instance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    static func getUser() -> User? {
        return AppDelegate.instance().user
    }
    
    static func getContext() -> NSManagedObjectContext? {
        return AppDelegate.managedObjectContext
    }
    
    static func studySauceCom(var path_and_query: String) -> NSURL! {
        if path_and_query.containsString("?") {
            path_and_query = path_and_query + "&XDEBUG_SESSION_START=PHPSTORM"
        }
        else {
            path_and_query = path_and_query + "?XDEBUG_SESSION_START=PHPSTORM"
        }
        return NSURL(string: "https://cerebro.studysauce.com\(path_and_query)")!
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true
        self.setupTheme()
        
        // Override point for customization after application launch.
        // TODO: check the local copy of the session timeout
        let done = {
            if self.storyboard == nil {
                self.storyboard = UIStoryboard(name: "Main", bundle: nil)
            }
            if self.window == nil {
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                let viewController = self.storyboard!.instantiateViewControllerWithIdentifier(AppDelegate.getUser() == nil ? "Landing" : "Home")
                viewController.transitioningDelegate = CardSegue.transitionManager
                self.window!.rootViewController = viewController
                viewController.view.clipsToBounds = false
                self.window!.backgroundColor = UIColor.clearColor()
                self.window!.opaque = false
                self.window!.makeKeyAndVisible();
            }
        }
        UserLoginController.home { () -> Void in
            dispatch_async(dispatch_get_main_queue(), done)
        }
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let query = url.getKeyVals()
        if query["token"] != nil {
            let reset = self.storyboard!.instantiateViewControllerWithIdentifier("PasswordReset") as! UserResetController
            reset.transitioningDelegate = CardSegue.transitionManager
            reset.token = url.getKeyVals()["token"]!
            reset.mail = url.getKeyVals()["email"]!
            self.window?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
            self.window?.rootViewController!.presentViewController(reset, animated: true, completion: {})
        }
        else if query["_code"] != nil && query["first"] != nil {
            let reg = self.storyboard!.instantiateViewControllerWithIdentifier("UserRegister") as! UserRegisterController
            reg.transitioningDelegate = CardSegue.transitionManager
            reg.registrationCode = query["_code"]!
            reg.first = query["first"]!
            reg.last = query["last"]!
            reg.mail = query["email"]!
            reg.token = query["csrf_token"]!
            self.window?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
            self.window?.rootViewController!.presentViewController(reg, animated: true, completion: {})
        }
        else if query["_code"] != nil {
            postJson("/register", params: ["_code": query["_code"]!], redirect: {(path) in
                    if path == "/home" {
                        UserLoginController.home({
                            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("Home")
                            viewController.transitioningDelegate = CardSegue.transitionManager
                            self.window?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
                            self.window?.rootViewController!.presentViewController(viewController, animated: true, completion: {})
                        })
                    }
            })
        }
        else {
            UserLoginController.home {
                if AppDelegate.getUser() != nil {
                    let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("Home")
                    viewController.transitioningDelegate = CardSegue.transitionManager
                    self.window?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
                    self.window?.rootViewController!.presentViewController(viewController, animated: true, completion: {})
                }
            }
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view
    
    static var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appcoda.Coredata" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    static private var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("StudySauce", withExtension: "momd")!
        return NSManagedObjectModel.mergedModelFromBundles(nil)! //NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    private static func getPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: AppDelegate.managedObjectModel)
        let url = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite") as NSURL
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }
        catch _ as NSError {
            return self.resetLocalStore()
        }
        return coordinator
    }
    
    internal static func resetLocalStore() -> NSPersistentStoreCoordinator? {
        return self.resetLocalStore(false)
    }
    
    internal static func resetLocalStore(manual: Bool) -> NSPersistentStoreCoordinator?
    {
        let url = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite") as NSURL
        do {
            try NSFileManager.defaultManager().removeItemAtPath(url.path!)
            let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: AppDelegate.managedObjectModel)
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            let managedObjectContext = NSManagedObjectContext()
            managedObjectContext.persistentStoreCoordinator = coordinator
            if manual {
                self.managedObjectContext = managedObjectContext
            }
            return coordinator
        }
        catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        return nil
    }
    
    static var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = AppDelegate.getPersistentStoreCoordinator()
        if coordinator == nil {
            return nil
        }
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        if let moc = AppDelegate.managedObjectContext {
            do {
                if moc.hasChanges {
                    try moc.save()
                }
            }
            catch let error as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(SCNetworkReachabilityFlags.Reachable)
        let needsConnection = flags.contains(SCNetworkReachabilityFlags.ConnectionRequired)
        
        return isReachable && !needsConnection
    }

}

