//
//  StudySauceUITests.swift
//  StudySauceUITests
//
//  Created by Brian Cullinan on 1/7/16.
//  Copyright © 2016 The Study Institute. All rights reserved.
//

import XCTest

class StudySauceUITests: XCTestCase {
    
    static let howLong = 60.0 // minutes
    static let randomize = true // false to do in order below
    static let doLogins = true
    static let doRegistrations = true
    static let functionsInOrder = ["testBigButton", "testLogin", "testRegistration", "testPackSummary", "testBigButton", "testPackSummary", "testBigButton", "testPackSummary", "testBigButton"]
    static var logins: Dictionary<String, String> = ["brian@studysauce.com": "password"]
    static let registrationCodes = ["ACS1A"]
    static let longWait = 20.0
    static let shortWait = 4.0
    
    func testEverything() {
        let until = Date().addingTimeInterval(TimeInterval(StudySauceUITests.howLong * 60.0))
        while until.compare(Date()) == ComparisonResult.orderedDescending {
            let choose = Int(arc4random_uniform(UInt32(StudySauceUITests.functionsInOrder.count)))
            if self.responds(to: Selector(StudySauceUITests.functionsInOrder[choose])) {
                self.perform(Selector(StudySauceUITests.functionsInOrder[choose]))
            }
        }
    }
    
    func testRotation() {
        
        let device = XCUIDevice.shared()
        device.orientation = UIDeviceOrientation.portrait
        
        self.testPackSummary()
        device.orientation = UIDeviceOrientation.landscapeRight

        self.testPackSummary()
    }
    
    func testAllKeys() {
        self.testReturnToHome()
        
        let app = XCUIApplication()
        
        app.buttons["gray Study packs icon with cle"].tap()
        
        // wait for loading to disappear
        expectation(for: NSPredicate(format: "exists==0 OR hittable=FALSE"), evaluatedWith: app.staticTexts["Loading..."], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
        expectation(for: NSPredicate(format: "count>0"), evaluatedWith: app.tables.cells, handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
        app.tables.element(boundBy: 0).scrollToElement(app.staticTexts["Math facts - 1"])
        expectation(for: NSPredicate(format: "hittable=TRUE"), evaluatedWith: app.staticTexts["Math facts - 1"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        app.staticTexts["Math facts - 1"].tap()
        
        // wait for the card to show up
        expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.staticTexts["pageCount"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
        let counts = app.staticTexts["pageCount"].label.components(separatedBy: " of ")
        let count = Int(counts[1])!
        let current = Int(counts[0])! - 1
        while current < count {
            let page = app.staticTexts["\(current+1) of \(count)"]
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: page, handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            app.textFields["fillblank"].tap()
            app.textFields["fillblank"].tap()
            expectation(for: NSPredicate(format: "hittable==true"), evaluatedWith: app.buttons["Done"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            // tap all number keys
            app.buttons["0"].tap()
            app.buttons["1"].tap()
            app.buttons["2"].tap()
            app.buttons["3"].tap()
            app.buttons["4"].tap()
            app.buttons["5"].tap()
            app.buttons["6"].tap()
            app.buttons["7"].tap()
            app.buttons["8"].tap()
            app.buttons["9"].tap()
            app.buttons["Done"].tap()
            
            // if it is wrong, click to the next answer
            expectation(for: NSPredicate(format: "ANY exists=TRUE"), evaluatedWith: [
                app.textViews["response"], app.textViews["prompt"], app.staticTexts["percent"]], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            if app.textViews["response"].exists {
                app.textViews["response"].tap()
            }
            
            expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: page, handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            break
        }
        
        self.testReturnToHome()
    }
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        self.testReturnToHome()
    }
    
    func testReturnToHome() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        
        // wait for the homescreen to load
        expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: app.activityIndicators.element(boundBy: 0), handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
        
        if app.buttons["Log in"].exists && app.buttons["Log in"].isHittable {
            self.testLogin()
        }
        else if app.otherElements["PopoverDismissRegion"].exists {
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.otherElements["users"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            app.buttons["username"].tap()
            
            expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: app.otherElements["users"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
        }
        else if app.staticTexts["Take the guesswork out of studying!"].exists {
            self.testTutorial()
        }
        else if app.buttons["shuffle"].exists && app.buttons["shuffle"].isHittable  {
            // already on home do nothing
            if app.otherElements["PopoverDismissRegion"].exists && app.otherElements["PopoverDismissRegion"].isHittable {
                app.otherElements["PopoverDismissRegion"].tap()
            }
            
        }
        else if app.buttons["BackButton"].exists && app.buttons["BackButton"].isHittable {
            expectation(for: NSPredicate(format: "hittable=TRUE"), evaluatedWith: app.buttons["BackButton"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            app.buttons["BackButton"].tap()
            self.testReturnToHome()
        }
        else {
            // fail if we get here
            XCTAssertTrue(false)
            
        }
        
        // wait for loading to disappear
        expectation(for: NSPredicate(format: "exists==0 OR hittable=FALSE"), evaluatedWith: app.staticTexts["Loading..."], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
    }
    
    func testPackSummary() {
        
        let app = XCUIApplication()
        
        app.buttons["gray Study packs icon with cle"].tap()

        // wait for loading to disappear
        expectation(for: NSPredicate(format: "exists==0 OR hittable=FALSE"), evaluatedWith: app.staticTexts["Loading..."], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}

        expectation(for: NSPredicate(format: "count>0"), evaluatedWith: app.tables.cells, handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}

        let total = app.cells.count
        let choose = UInt(arc4random_uniform(UInt32(total)))
        let row = app.tables.cells.element(boundBy: choose).staticTexts.element
        app.tables.element(boundBy: 0).scrollToElement(app.tables.cells.element(boundBy: choose))
        expectation(for: NSPredicate(format: "hittable=TRUE"), evaluatedWith: row, handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        row.tap()
        
        // wait for the card to show up
        expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.staticTexts["pageCount"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
        let counts = app.staticTexts["pageCount"].label.components(separatedBy: " of ")
        let count = Int(counts[1])!
        var current = Int(counts[0])! - 1
        while current < count {
            let page = app.staticTexts["\(current+1) of \(count)"]
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: page, handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            self.testAnswerCard()
            
            // if it is wrong, click to the next answer
            expectation(for: NSPredicate(format: "ANY exists=TRUE"), evaluatedWith: [
                app.textViews["response"], app.textViews["prompt"], app.staticTexts["percent"]], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            if app.textViews["response"].exists {
                app.textViews["response"].tap()
            }
            
            expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: page, handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
        
            current += 1
        }
        
        self.testReturnToHome()
    }
    
    func testAnswerCard() {
        
        let app = XCUIApplication()
        
        if app.textFields["fillblank"].exists {
            app.textFields["fillblank"].tap()
            app.textFields["fillblank"].tap()
            expectation(for: NSPredicate(format: "hittable==true"), evaluatedWith: app.buttons["Done"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            //UIPasteb2oard.generalPasteboard().string = "Hello World!"
            //textField.pressForDuration(1.1)
            //app.menuItems["Paste"].tap()
            //app.typeText("\n")
            app.buttons["Done"].tap()
        }
        else if app.staticTexts["Tap to see answer"].exists {
            app.staticTexts["Tap to see answer"].tap()
            let choose = Int(arc4random_uniform(2))
            if choose == 0 {
                app.buttons["✔︎"].tap()
            }
            else {
                app.buttons["✘"].tap()
            }
        }
        else if app.buttons["answer1"].exists {
            let choose = Int(arc4random_uniform(4) + 1)
            app.buttons["answer\(choose)"].tap()
        }
        else if app.buttons["True"].exists {
            let choose = Int(arc4random_uniform(2))
            if choose == 0 {
                app.buttons["True"].tap()
            }
            else {
                app.buttons["False"].tap()
            }
        }
    }
    
    func testBigButton() {
        
        let app = XCUIApplication()
        
        // get the total card count from the screen
        let total = app.staticTexts["totalCount"]
        expectation(for: NSPredicate(format: "hittable=TRUE"), evaluatedWith: total, handler: nil)
        waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
        var count = Int(total.label.replacingOccurrences(of: " cards", with: ""))!
        
        if count == 0 {
            return
        }
        
        // click big shuffle button
        let shuffle = app.buttons["shuffle"]
        expectation(for: NSPredicate(format: "hittable=TRUE"), evaluatedWith: shuffle, handler: nil)
        waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
        shuffle.tap()
        
        let counts = app.staticTexts["pageCount"].label.components(separatedBy: " of ")
        count = Int(counts[1])!
        var current = Int(counts[0])! - 1
        var correct = 0
        var wrong = 0
        while current < count {
            let page = app.staticTexts["\(current+1) of \(count)"]
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: page, handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            self.testAnswerCard()
            
            // if it is wrong, click to the next answer
            expectation(for: NSPredicate(format: "ANY exists=TRUE"), evaluatedWith: [
                app.textViews["response"], app.textViews["prompt"], app.staticTexts["percent"]], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            if app.textViews["response"].exists {
                wrong += 1
                app.textViews["response"].tap()
            }
            else {
                correct += 1
            }
            
            expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: page, handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            current += 1
        }
        XCTAssert(correct + wrong == count)
        
        // go back to home screen
        let percent = Int32(round(Double(correct) / Double(correct + wrong) * 100.0))
        expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.staticTexts["\(percent)%"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
        
        self.testReturnToHome()
    }
    
    func testSwitchUsers() {
        
        let app = XCUIApplication()
        expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.buttons["username"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
        app.buttons["username"].forceTapElement()

        let children = app.otherElements["users"].cells.count - 2
        let choose = UInt(arc4random_uniform(UInt32(children)) + 1)
        app.otherElements["users"].cells.element(boundBy: choose).tap()
        
        expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: app.otherElements["users"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
        
        self.testReturnToHome()
    }
    
    fileprivate static func getTime() -> String {
        let locale = Locale(identifier: "en_US")
        let timeZone = TimeZone(identifier: "GMT")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale //need locale for some iOS 9 verision, will not select correct default locale
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "ddMMHHmm"
        return dateFormatter.string(from: Date())
    }
    
    func testRegistration() {
        let app = XCUIApplication()
        
        if app.buttons["shuffle"].exists {
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.buttons["username"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            app.buttons["username"].forceTapElement()
            
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.otherElements["users"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            app.staticTexts["Logout"].forceTapElement()
        }
        
        expectation(for: NSPredicate(format: "exists=TRUE AND hittable=TRUE"), evaluatedWith: app.buttons["Sign up"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait, handler: nil)
        app.buttons["Sign up"].tap()
        
        let choose = Int(arc4random_uniform(UInt32(StudySauceUITests.registrationCodes.count)))
        app.textFields["Enter code to continue"].tap()
        app.textFields["Enter code to continue"].typeText(StudySauceUITests.registrationCodes[choose])
        app.buttons["invite"].tap()
        
        expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: app.buttons["Next"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
        app.textFields["Parent first name"].tap()
        app.textFields["Parent first name"].typeText("Test First")
        app.textFields["Last name"].tap()
        app.textFields["Last name"].typeText("Test Last")
        app.textFields["Email address"].tap()
        app.textFields["Email address"].typeText("test\(StudySauceUITests.getTime())@studysauce.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("password")
        
        app.textFields["childFirst"].tap()
        app.textFields["childFirst"].typeText("Child First")
        app.textFields["childLast"].tap()
        app.textFields["childLast"].typeText("Child Last")
        
        app.buttons["Register"].tap()
        
        expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: app.buttons["Register"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        
        StudySauceUITests.logins["test\(StudySauceUITests.getTime())@studysauce.com"] = "password"
        self.testReturnToHome()
    }
    
    func testTutorial() {
        let app = XCUIApplication()
        if app.staticTexts["Take the guesswork out of studying!"].exists {
            app.pageIndicators.element(boundBy: 0).tap()
            app.pageIndicators.element(boundBy: 0).tap()
            app.pageIndicators.element(boundBy: 0).tap()
        }
        self.testReturnToHome()
    }
    
    func testLogin() {
        let app = XCUIApplication()
        
        if app.buttons["shuffle"].exists {
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.buttons["username"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            app.buttons["username"].forceTapElement()
            
            expectation(for: NSPredicate(format: "exists=TRUE"), evaluatedWith: app.otherElements["users"], handler: nil)
            waitForExpectations(timeout: StudySauceUITests.shortWait) {_ in}
            
            app.staticTexts["Logout"].forceTapElement()
        }
        
        expectation(for: NSPredicate(format: "exists=TRUE AND hittable=TRUE"), evaluatedWith: app.buttons["Log in"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait, handler: nil)
        app.buttons["Log in"].tap()
        
        // randomly select an account to use
        let choose = Int(arc4random_uniform(UInt32(StudySauceUITests.logins.count)))
        let email = Array(StudySauceUITests.logins.keys)[choose]
        let password = StudySauceUITests.logins[email]
        app.textFields["Email address"].tap()
        app.textFields["Email address"].typeText(email)
        app.secureTextFields["Password"].tap()
        UIPasteboard.general.string = password
        app.secureTextFields["Password"].press(forDuration: 1.1)
        app.menuItems["Paste"].tap()

        
        app.buttons["Log in"].tap()
        
        expectation(for: NSPredicate(format: "exists=FALSE"), evaluatedWith: app.buttons["Log in"], handler: nil)
        waitForExpectations(timeout: StudySauceUITests.longWait) {_ in}
        self.testReturnToHome()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

/*Sends a tap event to a hittable/unhittable element.*/
extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
    
    func scrollToElement(_ element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }
    
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
    
}
