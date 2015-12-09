//
//  wiserIosTests.swift
//  wiserIosTests
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import XCTest
@testable import wiserIos

class wiserIosTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCreateRoom() {
        
        //Arrange
        let vc = CreateRoomViewController()
        
        vc.roomNameInputCell = TextInputCell()
        vc.roomNameInputCell?.inputField = UITextField()
        vc.roomSecretInputCell = TextInputCell()
        vc.roomSecretInputCell?.inputField = UITextField()
        vc.pwInputCell = TextInputCell()
        vc.pwInputCell?.inputField = UITextField()
        vc.pwInputCell?.inputField.enabled = false

        vc.roomNameInputCell?.inputField.text = "testRoom" + NSUUID().UUIDString
        vc.roomSecretInputCell?.inputField.text = "testSecret" + NSUUID().UUIDString
        
        CurrentUser.sharedInstance._id = "system"
        CurrentUser.sharedInstance.location.Longitude = Double.random(10.188355, 10.188355)
        CurrentUser.sharedInstance.location.Latitude = Double.random(56.171898, 56.171898)
        
        //Act
        vc.addRoomBtn(UIBarButtonItem())
        
        usleep(1000*100)
        
        //Assert
        XCTAssert(true)
    }
    
    func testCreateManyRooms() {
        for _ in 0..<1 {
            testCreateRoom()
        }
        sleep(180)
        XCTAssert(true)
    }
    
}
