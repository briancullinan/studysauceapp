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
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate, HarpyDelegate, SKPaymentTransactionObserver {

    internal static var cart: Array<String> = []
    internal static var cartChildren: Dictionary<String, NSNumber> = [:]
    var isRotating = false
    var needsUpdating = false
    var timeout = 60.0 * 10
    internal var device: String? = nil
    var window: UIWindow?
    var storyboard: UIStoryboard?
    var user: User? {
        didSet {
            if user == nil {
                let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for c in storage.cookies! {
                    storage.deleteCookie(c)
                }
            }

            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(user?.email, forKey: "user")
            userDefaults.synchronize() // don't forget this!!!!
            
            if user != nil {
                let cookies = user!.getProperty("session") as? [[String : AnyObject]] ?? [[String : AnyObject]]()
                for var cookie in cookies {
                    cookie["Expires"] = NSDate.parse(cookie["Expires"] as? String)
                    let otherCookie = NSHTTPCookie(properties: cookie)!
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(otherCookie)
                }
            }
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let home = AppDelegate.visibleViewController() as? HomeController {
            doMain(home.homeSync)
        }
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = "\(deviceToken)"
        getJson("/account/update", ["device" : token.stringByReplacingOccurrencesOfString("<", withString: "")
            .stringByReplacingOccurrencesOfString(">", withString: "")
            .stringByReplacingOccurrencesOfString(" ", withString: "")])
    }
    
    static var lastTouch = NSDate()
    
    static func visibleViewController() -> UIViewController {
        return self.visibleViewController(AppDelegate.instance().window!.rootViewController!)
    }
    
    static func visibleViewController(rootViewController: UIViewController) -> UIViewController
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
    
    static func insert<A: NSManagedObject>(a: A.Type) -> A {
        return AppDelegate.managedObjectContext!.insert(a)
    }
    
    static func get<A: NSManagedObject>(a: A.Type, _ id: NSNumber) -> A? {
        let fetchRequest = NSFetchRequest(entityName: "\(a)")
        let predicate = NSPredicate(format: "id=\(id)")
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        let result = try? AppDelegate.managedObjectContext!.executeFetchRequest(fetchRequest).first
        return result as? A
    }
    
    static func getPredicate<A: NSManagedObject>(a: A.Type, _ pred: NSPredicate) -> [A] {
        let fetchRequest = NSFetchRequest(entityName: "\(a)")
        fetchRequest.predicate = pred
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        let result = try? AppDelegate.managedObjectContext!.executeFetchRequest(fetchRequest)
        return result as? [A] ?? []
    }

    static func getLast<A: NSManagedObject>(a: A.Type, _ pred: NSPredicate) -> A? {
        let fetchRequest = NSFetchRequest(entityName: "\(a)")
        fetchRequest.predicate = pred
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        let result = try? AppDelegate.managedObjectContext!.executeFetchRequest(fetchRequest).first
        return result as? A
    }
    
    static func getMax<A: NSManagedObject>(a: A.Type, _ pred: String) -> A? {
        let fetchRequest = NSFetchRequest(entityName: "\(a)")
        let predicate = NSPredicate(format: pred)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        let result = try? AppDelegate.managedObjectContext!.executeFetchRequest(fetchRequest).first
        return result as? A
    }

    static func deleteObject(obj: NSManagedObject) {
        AppDelegate.managedObjectContext?.deleteObject(obj)
    }
    
    static func performContext(perform: () -> Void) -> Void {
        AppDelegate.managedObjectContext?.performBlock(perform)
    }
    
    static func list<A: NSManagedObject>(t: A.Type) -> [A] {
        return AppDelegate.managedObjectContext!.list(t)
    }
    
    static var domain: String {
        #if DEBUG
            return "test.studysauce.com"
        #else
            let receiptUrl = NSBundle.mainBundle().appStoreReceiptURL?.path
            if receiptUrl?.containsString("sandboxReceipt") == true {
                return "test.studysauce.com"
            }
            return "cerebro.studysauce.com"
        #endif
    }
    
    static func studySauceCom(path_and_query: String) -> NSURL! {
        var newPathQuery = path_and_query
        #if DEBUG
            if newPathQuery.containsString("?") {
                newPathQuery = path_and_query + "&XDEBUG_SESSION_START=PHPSTORM"
            }
            else {
                newPathQuery = path_and_query + "?XDEBUG_SESSION_START=PHPSTORM"
            }
        #endif
        return NSURL(string: "https://\(self.domain)\(newPathQuery)")!
    }
    
    static func goHome (fromView: UIViewController? = nil, _ refetch: Bool = false, _ done: (v: UIViewController) -> Void = {_ in}) {
        if self.instance().storyboard == nil {
            self.instance().storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        let handleUser = {
            AppDelegate.performContext({
                let user = AppDelegate.getUser()
                let home: UIViewController
                if user == nil {
                    home = self.instance().storyboard!.instantiateViewControllerWithIdentifier("Landing")
                }
                else if user!.getProperty("seen_tutorial") as? Bool != true && !(NSUserDefaults.standardUserDefaults().valueForKey("seen_tutorial") as? String ?? "").componentsSeparatedByString(",").filter({$0 != ""}).map({Int($0)}).filter({$0 != nil}).map({$0!}).contains(Int(user!.id!))
                {
                    user!.setProperty("seen_tutorial", true)
                    AppDelegate.saveContext()
                    home = self.instance().storyboard!.instantiateViewControllerWithIdentifier("Tutorial")
                }
                else {
                    home = self.instance().storyboard!.instantiateViewControllerWithIdentifier("Home")
                    UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil))
                    self.isMultiuser = AppDelegate.list(User.self).filter({$0.user_packs?.count > 0}).count > 1
                    if self.isMultiuser {
                        self.firstTimeLoad = true
                    }
                }
                doMain {
                    if self.instance().window == nil {
                        self.instance().window = UIWindow(frame: UIScreen.mainScreen().bounds)
                        self.instance().window!.rootViewController = home
                        self.instance().window!.backgroundColor = UIColor.clearColor()
                        self.instance().window!.opaque = false
                        self.instance().window!.makeKeyAndVisible();
                        home.transitioningDelegate = CardSegue.transitionManager
                        done(v: home)
                    }
                    else if fromView == nil {
                        home.transitioningDelegate = CardSegue.transitionManager
                        
                        if !self.instance().window!.rootViewController!.isTypeOf(home) {
                            if self.instance().window!.rootViewController!.presentedViewController == nil {
                                self.instance().window!.rootViewController!.presentViewController(home, animated: true) {
                                    if self.firstTimeLoad {
                                        (home as! HomeController).userClick((home as! HomeController).userButton!)
                                    }
                                    done(v: home)
                                }
                            }
                            else {
                                self.instance().window!.rootViewController!.dismissViewControllerAnimated(false) {
                                    self.instance().window!.rootViewController!.presentViewController(home, animated: true) {
                                        done(v: home)
                                    }
                                }
                            }
                        }
                        else {
                            self.instance().window!.rootViewController!.dismissViewControllerAnimated(true) {
                                done(v: self.instance().window!.rootViewController!)
                            }
                        }
                    }
                    else {
                        home.transitioningDelegate = CardSegue.transitionManager
                        fromView!.transitioningDelegate = CardSegue.transitionManager
                        fromView!.presentViewController(home, animated: true, completion: {
                            done(v: home)
                        })
                    }
                }
            })
        }
        
        if !refetch && AppDelegate.getUser() != nil {
            handleUser()
        }
        else {
            UserLoginController.home {
                handleUser()
            }
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = saucyTheme.textSize + saucyTheme.padding * 3;
        self.setupTheme()
        Harpy.sharedInstance().appID = "1065647027"
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

        // Override point for customization after application launch.
        // TODO: check the local copy of the session timeout
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.synchronize() // don't forget this!!!!
        let email = userDefaults.valueForKey("user") as? String
        if AppDelegate.isConnectedToNetwork() {
            UserLoginController.home { () -> Void in
                AppDelegate.performContext({
                    //if let user = AppDelegate.list(User.self).filter({$0.email == email}).first {
                    //    self.user = user
                    //}
                    doMain {
                        AppDelegate.goHome {_ in self.afterHome() }
                    }
                })
            }
        }
        else {
            // TODO: work in offline mode
            if let user = AppDelegate.list(User.self).filter({$0.email == email}).first {
                self.user = user
                AppDelegate.goHome {_ in self.afterHome() }
            }
            else {
                AppDelegate.goHome {v in
                    v.showNoConnectionDialog { () -> Void in
                        UserLoginController.home { () -> Void in
                            AppDelegate.goHome {_ in self.afterHome() }
                        }
                    }
                }
            }
        }
        
        // timeout timer
        NSTimer.scheduledTimerWithTimeInterval(1,
            target: self, selector: #selector(AppDelegate.checkTimeout), userInfo: nil, repeats: true)
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        //gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        return true
    }
    
    func checkTimeout () {
        if AppDelegate.lastTouch < NSDate().dateByAddingTimeInterval(-self.timeout) {
            self.didTimeout()
            AppDelegate.lastTouch = NSDate()
        }
    }
    
    func harpyDidDetectNewVersionWithoutAlert(message: String!) {
        self.needsUpdating = true
        let completed = {
            AppDelegate.visibleViewController().showDialog(NSLocalizedString("A new version is now available.", comment: "Message text for new version dialog"), NSLocalizedString("Update", comment: "Update button on new version"), click: {
                let iTunesURL = NSURL(string: "https://itunes.apple.com/app/id\(Harpy.sharedInstance().appID)")!
                UIApplication.sharedApplication().openURL(iTunesURL)
                return false
            })
        }
        doMain {
            if AppDelegate.visibleViewController() is UserSwitchController {
                AppDelegate.visibleViewController().dismissViewControllerAnimated(false, completion: {
                    completed()
                })
            }
            else {
                completed()
            }
        }
    }
    
    static var isMultiuser = false
    static var firstTimeLoad = false
    
    func afterHome() {
        AppDelegate.firstTimeLoad = false
        Harpy.sharedInstance().delegate = self
        Harpy.sharedInstance().presentingViewController = AppDelegate.visibleViewController()
        Harpy.sharedInstance().alertType = .None
        Harpy.sharedInstance().checkVersion()
    }
    
    func didTimeout() {
        
        if !self.needsUpdating {
            
            if self.window == nil || self.user == nil || !AppDelegate.isMultiuser {
                return
            }
            
            if !(AppDelegate.visibleViewController() is UserSwitchController) {
                if let home = AppDelegate.visibleViewController() as? HomeController {
                    home.userClick(home.userButton!)
                }
                else {
                    AppDelegate.goHome {home in
                        let h = home as! HomeController
                        h.userClick(h.userButton!)
                    }
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let query = url.getKeyVals()
        if query["token"] != nil {
            let reset = self.storyboard!.instantiateViewControllerWithIdentifier("PasswordReset") as! UserResetController
            reset.transitioningDelegate = CardSegue.transitionManager
            reset.token = url.getKeyVals()["token"]!
            reset.mail = url.getKeyVals()["email"]!
            AppDelegate.goHome {home in
                home.presentViewController(reset, animated: true, completion: {})
            }
        }
        else if query["_code"] != nil && query["first"] != nil {
            let reg = self.storyboard!.instantiateViewControllerWithIdentifier("UserRegister") as! UserRegisterController
            reg.transitioningDelegate = CardSegue.transitionManager
            reg.registrationCode = query["_code"]!
            reg.first = query["first"]!
            reg.last = query["last"]!
            reg.mail = query["email"]!
            reg.token = query["csrf_token"]!
            AppDelegate.goHome {home in
                home.presentViewController(reg, animated: true, completion: {})
            }
        }
        else if query["_code"] != nil {
            postJson("/register", ["_code": query["_code"]!], redirect: {(path: String) in
                if path == "/home" {
                    UserLoginController.home {
                        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("Home")
                        viewController.transitioningDelegate = CardSegue.transitionManager
                        self.window?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
                        self.window?.rootViewController!.presentViewController(viewController, animated: true, completion: {})
                    }
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
        if let home = AppDelegate.visibleViewController() as? HomeController {
            home.stopTasks()
        }
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.checkTimeout()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
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
        let url = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("StudySauceCache.sqlite") as NSURL
        do {
            //var options = Dictionary<NSObject, AnyObject>()
            //options[NSMigratePersistentStoresAutomaticallyOption] = true
            //options[NSInferMappingModelAutomaticallyOption] = true
            //options["journal_mode"] = "DELETE"
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }
        catch _ as NSError {
            return self.resetLocalStore(false)
        }
        return coordinator
    }
    
    internal static func resetLocalStore() -> NSPersistentStoreCoordinator? {
        return self.resetLocalStore(true)
    }
    
    private static func resetLocalStore(manual: Bool) -> NSPersistentStoreCoordinator?
    {
        // try to save users and cookies
                
        let url = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("StudySauceCache.sqlite") as NSURL
        //try? self.managedObjectContext?.persistentStoreCoordinator?.destroyPersistentStoreAtURL(url, withType: NSSQLiteStoreType, options: nil)
        try? NSFileManager.defaultManager().removeItemAtPath(url.path!)
        try? NSFileManager.defaultManager().removeItemAtPath("\(url.path!)-wal")
        try? NSFileManager.defaultManager().removeItemAtPath("\(url.path!)-shm")
        let coordinator = AppDelegate.getPersistentStoreCoordinator()
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        self.managedObjectContext = managedObjectContext
        return coordinator
    }
    
    private static var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = AppDelegate.getPersistentStoreCoordinator()
        if coordinator == nil {
            return nil
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
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
                // Replace this implemesntation with code to handle the error appropriately.
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
    
    var transactions: [SKPaymentTransaction] = []
    static var storeChild: User? = nil
    static var storeCoupon: String? = ""
    internal func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased, .Restored:
                if AppDelegate.storeChild == nil || AppDelegate.storeCoupon == nil {
                    self.transactions.append(transaction)
                    break
                }
                postJson("/checkout/pay", ["coupon" : AppDelegate.storeCoupon!,
                    "child" : [AppDelegate.storeChild!.id! : AppDelegate.storeCoupon!],
                    "purchase_token" : transaction.transactionIdentifier
                ]) {_ in
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    AppDelegate.cart.removeAtIndex(AppDelegate.cart.indexOf(AppDelegate.storeCoupon!)!)
                    //AppDelegate.completed.append(AppDelegate.storeCoupon!)
                    (AppDelegate.visibleViewController() as? UserSelectController)?.dismissViewControllerAnimated(true, completion: {
                        (AppDelegate.visibleViewController() as? StoreController)?.completed = true
                        (AppDelegate.visibleViewController() as? StoreController)?.updateCart()
                        (AppDelegate.visibleViewController() as? StoreController)?.tableView.reloadData()
                    })
                }
                break
            case .Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            default:
                break
            }
        }
    }
    

}

