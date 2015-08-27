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
    
    
    //JSONSerializer tests
    func stringCompareHelper(actual: String, _ expected: String) {
        XCTAssertTrue(expected == actual, "expected value:\(expected) not equal to actual:\(actual)")
    }
    
    func test_string_apple() {
        //Arrange
        class TestClass {
            var name = "apple"
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"name\": \"apple\"}"
        stringCompareHelper(json, expected)
    }
    
    func test_optionalString_nil() {
        //Arrange
        class TestClass {
            var name: String? = nil
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"name\": null}"
        stringCompareHelper(json, expected)
    }
    
    func test_optionalString_apple() {
        //Arrange
        class TestClass {
            var name: String? = "apple"
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"name\": \"apple\"}"
        stringCompareHelper(json, expected)
    }
    
    func test_double_2dot1() {
        //Arrange
        class TestClass {
            var weight = 2.1
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"weight\": 2.1}"
        stringCompareHelper(json, expected)
    }
    
    func test_optionalDouble_nil() {
        //Arrange
        class TestClass {
            var weight: Double? = nil
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"weight\": null}"
        stringCompareHelper(json, expected)
    }
    
    func test_bool_true() {
        //Arrange
        class TestClass {
            var delicious = true
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"delicious\": true}"
        stringCompareHelper(json, expected)
    }
    
    func test_optionalBool_nil() {
        //Arrange
        class TestClass {
            var delicious: Bool? = nil
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"delicious\": null}"
        stringCompareHelper(json, expected)
    }
    
    func test_date_specificDate() {
        //Arrange
        class TestClass {
            var date = NSDate(timeIntervalSince1970: NSTimeInterval(1440430564))
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"date\": \"2015-08-24 15:36:04 +0000\"}"
        stringCompareHelper(json, expected)
    }
    
    func test_intArray_1234() {
        //Arrange
        class TestClass {
            var array = [1, 2, 3, 4]
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"array\": [1, 2, 3, 4]}"
        stringCompareHelper(json, expected)
    }
    
    func test_optionalIntArray_1nil34() {
        //Arrange
        class TestClass {
            var array: [Int?] = [1, nil, 3, 4]
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"array\": [1, null, 3, 4]}"
        stringCompareHelper(json, expected)
    }
    
    func test_doubleArray_1dot12dot23dot3() {
        //Arrange
        class TestClass {
            var array = [1.1, 2.2, 3.3]
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"array\": [1.1, 2.2, 3.3]}"
        stringCompareHelper(json, expected)
    }
    
    func test_optionalDoubleArray_1dot1nil3dot3() {
        //Arrange
        class TestClass {
            var array: [Double?] = [1.1, nil, 3.3]
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"array\": [1.1, null, 3.3]}"
        stringCompareHelper(json, expected)
    }
    
    func test_stringArray_helloDogCat() {
        //Arrange
        class TestClass {
            var array = ["hello", "dog", "cat"]
        }
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"array\": [\"hello\", \"dog\", \"cat\"]}"
        stringCompareHelper(json, expected)
    }
    
    func test_object_recursive() {
        //Arrange
        class Child {
            var name = "Vitamin"
            var amount = 4.2
            var intArray = [1, 5, 9]
            var stringArray = ["nutrients", "are", "important"]
        }
        class TestClass {
            var child = Child()
        }
        
        
        let m = TestClass()
        
        //Act
        let json = JSONSerializer.toJson(m)
        
        //Assert
        let expected = "{\"child\": {\"name\": \"Vitamin\", \"amount\": 4.2, \"intArray\": [1, 5, 9], \"stringArray\": [\"nutrients\", \"are\", \"important\"]}}"
        stringCompareHelper(json, expected)
    }

    
}
