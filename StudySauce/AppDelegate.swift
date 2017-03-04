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
import IQKeyboardManagerSwift
import Harpy


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
                let storage = HTTPCookieStorage.shared
                for c in storage.cookies! {
                    storage.deleteCookie(c)
                }
            }

            let userDefaults = UserDefaults.standard
            userDefaults.setValue(user?.email, forKey: "user")
            userDefaults.synchronize() // don't forget this!!!!
            
            if user != nil {
                if let data = Data.init(base64Encoded: user!.getProperty("session") as! String) {
                    let cookies = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[String : AnyObject]]
                    for cookie in cookies {
                        var loadedCookie = [HTTPCookiePropertyKey: AnyObject]()
                        for c in cookie {
                            if c.key == "Expires" {
                                let date = Date.parse(c.value as? String)
                                loadedCookie[HTTPCookiePropertyKey(rawValue: c.key)] = date as AnyObject?
                            }
                            else {
                                loadedCookie[HTTPCookiePropertyKey(rawValue: c.key)] = c.value
                            }
                        }
                        let otherCookie = HTTPCookie(properties: loadedCookie)!
                        HTTPCookieStorage.shared.setCookie(otherCookie)
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let home = AppDelegate.visibleViewController() as? HomeController {
            doMain(home.homeSync)
        }
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = "\(deviceToken)"
        getJson("/account/update", [
            "device" : token.replacingOccurrences(of: "<", with: "")
                .replacingOccurrences(of: ">", with: "")
                .replacingOccurrences(of: " ", with: "") as Optional<AnyObject>
            ])
    }
    
    static var lastTouch = Date()
    
    static func visibleViewController() -> UIViewController {
        return self.visibleViewController(AppDelegate.instance().window!.rootViewController!)
    }
    
    static func visibleViewController(_ rootViewController: UIViewController) -> UIViewController
    {
        let presentedViewController = rootViewController.presentedViewController;
        if rootViewController.presentedViewController == nil {
            return rootViewController
        }
        
        return self.visibleViewController(presentedViewController!);
    }
    
    static func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static func getUser() -> User? {
        return AppDelegate.instance().user
    }
    
    static func insert<A: NSManagedObject>(_ a: A.Type) -> A {
        return AppDelegate.managedObjectContext!.insert(a)
    }
    
    static func get<A: NSManagedObject>(_ a: A.Type, _ id: NSNumber) -> A? {
        let fetchRequest = NSFetchRequest<A>(entityName: "\(a)")
        let predicate = NSPredicate(format: "id=\(id)")
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        if let result = try? AppDelegate.managedObjectContext!.fetch(fetchRequest).first {
            return result
        }
        return nil
    }
    
    static func getPredicate<A: NSManagedObject>(_ a: A.Type, _ pred: NSPredicate) -> [A] {
        let fetchRequest = NSFetchRequest<A>(entityName: "\(a)")
        fetchRequest.predicate = pred
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        let result = try? AppDelegate.managedObjectContext!.fetch(fetchRequest)
        return result ?? []
    }

    static func getLast<A: NSManagedObject>(_ a: A.Type, _ pred: NSPredicate) -> A? {
        let fetchRequest = NSFetchRequest<A>(entityName: "\(a)")
        fetchRequest.predicate = pred
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        if let result = try? AppDelegate.managedObjectContext!.fetch(fetchRequest).first {
            return result
        }
        return nil
    }
    
    static func getMax<A: NSManagedObject>(_ a: A.Type, _ pred: String) -> A? {
        let fetchRequest = NSFetchRequest<A>(entityName: "\(a)")
        let predicate = NSPredicate(format: pred)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        if let result = try? AppDelegate.managedObjectContext!.fetch(fetchRequest).first {
            return result
        }
        return nil
    }

    static func deleteObject(_ obj: NSManagedObject) {
        AppDelegate.managedObjectContext?.delete(obj)
    }
    
    static func performContext(_ perform: @escaping () -> Void) -> Void {
        AppDelegate.managedObjectContext?.perform(perform)
    }
    
    static func list<A: NSManagedObject>(_ t: A.Type) -> [A] {
        return AppDelegate.managedObjectContext!.list(t)
    }
    
    static var domain: String {
        #if DEBUG
            return "cerebro.studysauce.com"
        #else
            let receiptUrl = Bundle.main.appStoreReceiptURL?.path
            if receiptUrl?.contains("sandboxReceipt") == true {
                return "cerebro.studysauce.com"
            }
            return "cerebro.studysauce.com"
        #endif
    }
    
    static func studySauceCom(_ path_and_query: String) -> URL! {
        var newPathQuery = path_and_query
        #if DEBUG
            if newPathQuery.contains("?") {
                newPathQuery = path_and_query + "&XDEBUG_SESSION_START=PHPSTORM"
            }
            else {
                newPathQuery = path_and_query + "?XDEBUG_SESSION_START=PHPSTORM"
            }
        #endif
        return URL(string: "https://\(self.domain)\(newPathQuery)")!
    }
    
    static func goHome (_ fromView: UIViewController? = nil, _ refetch: Bool = false, _ done: @escaping (_ v: UIViewController) -> Void = {_ in}) {
        if self.instance().storyboard == nil {
            self.instance().storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        let handleUser = {
            AppDelegate.performContext({
                let user = AppDelegate.getUser()
                let home: UIViewController
                if user == nil {
                    home = self.instance().storyboard!.instantiateViewController(withIdentifier: "Landing")
                }
                else if user!.getProperty("seen_tutorial") as? Bool != true && !(UserDefaults.standard.value(forKey: "seen_tutorial") as? String ?? "").components(separatedBy: ",").filter({$0 != ""}).map({Int($0)}).filter({$0 != nil}).map({$0!}).contains(Int(user!.id!))
                {
                    user!.setProperty("seen_tutorial", true as AnyObject)
                    AppDelegate.saveContext()
                    home = self.instance().storyboard!.instantiateViewController(withIdentifier: "Tutorial")
                }
                else {
                    home = self.instance().storyboard!.instantiateViewController(withIdentifier: "Home")
                    UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert], categories: nil))
                    self.isMultiuser = AppDelegate.list(User.self).filter({$0.user_packs?.count > 0}).count > 1
                    if self.isMultiuser {
                        self.firstTimeLoad = true
                    }
                }
                doMain {
                    if self.instance().window == nil {
                        self.instance().window = UIWindow(frame: UIScreen.main.bounds)
                        self.instance().window!.rootViewController = home
                        self.instance().window!.backgroundColor = UIColor.clear
                        self.instance().window!.isOpaque = false
                        self.instance().window!.makeKeyAndVisible();
                        home.transitioningDelegate = CardSegue.transitionManager
                        done(home)
                    }
                    else if fromView == nil {
                        home.transitioningDelegate = CardSegue.transitionManager
                        
                        if !self.instance().window!.rootViewController!.isTypeOf(home) {
                            if self.instance().window!.rootViewController!.presentedViewController == nil {
                                self.instance().window!.rootViewController!.present(home, animated: true) {
                                    if self.firstTimeLoad {
                                        (home as! HomeController).userClick((home as! HomeController).userButton!)
                                    }
                                    done(home)
                                }
                            }
                            else {
                                self.instance().window!.rootViewController!.dismiss(animated: false) {
                                    self.instance().window!.rootViewController!.present(home, animated: true) {
                                        done(home)
                                    }
                                }
                            }
                        }
                        else {
                            self.instance().window!.rootViewController!.dismiss(animated: true) {
                                done(self.instance().window!.rootViewController!)
                            }
                        }
                    }
                    else {
                        home.transitioningDelegate = CardSegue.transitionManager
                        fromView!.transitioningDelegate = CardSegue.transitionManager
                        fromView!.present(home, animated: true, completion: {
                            done(home)
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = saucyTheme.textSize + saucyTheme.padding * 3;
        self.setupTheme()
        SKPaymentQueue.default().add(self)

        // Override point for customization after application launch.
        // TODO: check the local copy of the session timeout
        let userDefaults = UserDefaults.standard
        userDefaults.synchronize() // don't forget this!!!!
        let email = userDefaults.value(forKey: "user") as? String
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
        Timer.scheduledTimer(timeInterval: 1,
            target: self, selector: #selector(AppDelegate.checkTimeout), userInfo: nil, repeats: true)
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        GAI.sharedInstance().defaultTracker?.set(kGAIScreenName, value: "")
        //gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        return true
    }
    
    func checkTimeout () {
        if AppDelegate.lastTouch < Date().addingTimeInterval(-self.timeout) {
            self.didTimeout()
            AppDelegate.lastTouch = Date()
        }
    }
    
    func harpyDidDetectNewVersionWithoutAlert(_ message: String!) {
        self.needsUpdating = true
        let completed = {
            AppDelegate.visibleViewController().showDialog(NSLocalizedString("A new version is now available.", comment: "Message text for new version dialog"), NSLocalizedString("Update", comment: "Update button on new version"), click: {
                let iTunesURL = URL(string: "https://itunes.apple.com/app/id1065647027")!
                UIApplication.shared.openURL(iTunesURL)
                return false
            })
        }
        doMain {
            if AppDelegate.visibleViewController() is UserSwitchController {
                AppDelegate.visibleViewController().dismiss(animated: false, completion: {
                    let _ = completed()
                })
            }
            else {
                let _ = completed()
            }
        }
    }
    
    static var isMultiuser = false
    static var firstTimeLoad = false
    
    func afterHome() {
        AppDelegate.firstTimeLoad = false
        Harpy.sharedInstance().delegate = self
        Harpy.sharedInstance().presentingViewController = AppDelegate.visibleViewController()
        Harpy.sharedInstance().alertType = .none
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
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let query = url.getKeyVals()
        if query["token"] != nil {
            let reset = self.storyboard!.instantiateViewController(withIdentifier: "PasswordReset") as! UserResetController
            reset.transitioningDelegate = CardSegue.transitionManager
            reset.token = url.getKeyVals()["token"]!
            reset.mail = url.getKeyVals()["email"]!
            AppDelegate.goHome {home in
                home.present(reset, animated: true, completion: {})
            }
        }
        else if query["_code"] != nil && query["first"] != nil {
            let reg = self.storyboard!.instantiateViewController(withIdentifier: "UserRegister") as! UserRegisterController
            reg.transitioningDelegate = CardSegue.transitionManager
            reg.registrationCode = query["_code"]!
            reg.first = query["first"]!
            reg.last = query["last"]!
            reg.mail = query["email"]!
            reg.token = query["csrf_token"]!
            AppDelegate.goHome {home in
                home.present(reg, animated: true, completion: {})
            }
        }
        else if query["_code"] != nil {
            postJson("/register", [
                "_code": query["_code"]! as Optional<AnyObject>
                ], redirect: {(path: String) in
                if path == "/home" {
                    UserLoginController.home {
                        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Home")
                        viewController.transitioningDelegate = CardSegue.transitionManager
                        self.window?.rootViewController!.dismiss(animated: false, completion: nil)
                        self.window?.rootViewController!.present(viewController, animated: true, completion: {})
                    }
                }
            })
        }
        else {
            UserLoginController.home {
                if AppDelegate.getUser() != nil {
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Home")
                    viewController.transitioningDelegate = CardSegue.transitionManager
                    self.window?.rootViewController!.dismiss(animated: false, completion: nil)
                    self.window?.rootViewController!.present(viewController, animated: true, completion: {})
                }
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        if let home = AppDelegate.visibleViewController() as? HomeController {
            home.stopTasks()
        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.checkTimeout()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view
    
    static var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appcoda.Coredata" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask)
        return urls[urls.count-1]
        }()
    
    static fileprivate var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "StudySauce", withExtension: "momd")!
        return NSManagedObjectModel.mergedModel(from: nil)! //NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    fileprivate static func getPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: AppDelegate.managedObjectModel)
        let url = AppDelegate.applicationDocumentsDirectory.appendingPathComponent("StudySauceCache.sqlite") as URL
        do {
            //var options = Dictionary<NSObject, AnyObject>()
            //options[NSMigratePersistentStoresAutomaticallyOption] = true
            //options[NSInferMappingModelAutomaticallyOption] = true
            //options["journal_mode"] = "DELETE"
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        }
        catch _ as NSError {
            return self.resetLocalStore(false)
        }
        return coordinator
    }
    
    internal static func resetLocalStore() -> NSPersistentStoreCoordinator? {
        return self.resetLocalStore(true)
    }
    
    fileprivate static func resetLocalStore(_ manual: Bool) -> NSPersistentStoreCoordinator?
    {
        // try to save users and cookies
                
        let url = AppDelegate.applicationDocumentsDirectory.appendingPathComponent("StudySauceCache.sqlite") as URL
        //try? self.managedObjectContext?.persistentStoreCoordinator?.destroyPersistentStoreAtURL(url, withType: NSSQLiteStoreType, options: nil)
        try? FileManager.default.removeItem(atPath: url.path)
        try? FileManager.default.removeItem(atPath: "\(url.path)-wal")
        try? FileManager.default.removeItem(atPath: "\(url.path)-shm")
        let coordinator = AppDelegate.getPersistentStoreCoordinator()
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        self.managedObjectContext = managedObjectContext
        return coordinator
    }
    
    fileprivate static var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = AppDelegate.getPersistentStoreCoordinator()
        if coordinator == nil {
            return nil
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
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
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(SCNetworkReachabilityFlags.reachable)
        let needsConnection = flags.contains(SCNetworkReachabilityFlags.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    var transactions: [SKPaymentTransaction] = []
    static var storeChild: User? = nil
    static var storeCoupon: String? = ""
    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                if AppDelegate.storeChild == nil || AppDelegate.storeCoupon == nil {
                    self.transactions.append(transaction)
                    break
                }
                postJson("/checkout/pay", ["coupon" : AppDelegate.storeCoupon! as Optional<AnyObject>,
                    "child" : [AppDelegate.storeCoupon! : AppDelegate.storeChild!.id!] as Optional<AnyObject>,
                    "purchase_token" : transaction.transactionIdentifier as Optional<AnyObject>
                ]) {_ in
                    SKPaymentQueue.default().finishTransaction(transaction)
                    //AppDelegate.completed.append(AppDelegate.storeCoupon!)
                    (AppDelegate.visibleViewController() as? UserSelectController)?.dismiss(animated: true, completion: {
                        (AppDelegate.visibleViewController() as? StoreController)?.completed = true
                        (AppDelegate.visibleViewController() as? StoreController)?.updateCart()
                        (AppDelegate.visibleViewController() as? StoreController)?.tableView.reloadData()
                    })
                }
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                break
            }
        }
    }
    

}

