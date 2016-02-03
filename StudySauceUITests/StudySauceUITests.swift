//
//  StudySauceUITests.swift
//  StudySauceUITests
//
//  Created by Brian Cullinan on 1/7/16.
//  Copyright © 2016 The Study Institute. All rights reserved.
//

import XCTest

class StudySauceUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReturnToHome() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        
        expectationForPredicate(NSPredicate(format: "exists == 1 && isHittable == 1"), evaluatedWithObject: app.buttons["Log in"], handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        app.buttons["Log in"].tap()
    }
    
}
