//
//  JSONSerializer.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

//This is an ongoing effort by me which has been posted in various versions on github as gists and or questions on forums like stackoverflow etc.
//See JSONSerializerTests

import Foundation

public class JSONSerializer {
    
    //http://stackoverflow.com/questions/30480672/how-to-convert-a-json-string-to-a-dictionary
    //Todo Make throwable
    public static func toDictionary(jsonString: String) -> NSDictionary? {
        let dictionary = jsonToAnyObject(jsonString) as? NSDictionary
        return dictionary
    }
    
    //Todo Make throwable
    public static func toArray(jsonString: String) -> NSArray? {
        let array = jsonToAnyObject(jsonString) as? NSArray
        return array
    }
    
    //Todo Make throwable
    private static func jsonToAnyObject(jsonString: String) -> AnyObject? {
        var any: AnyObject? = nil
        
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                any = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            }
            catch let error as NSError {
                let sError = String(error)
                NSLog(sError)
            }
        }
        return any
    }
    
    public static func toJson(object: Any) -> String {
        var json = "{"
        let mirror = Mirror(reflecting: object)
        
        var children = [(label: String?, value: Any)]()
        let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children)!
        children += mirrorChildrenCollection
        
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror()?.children {
            let randomCollection = AnyRandomAccessCollection(superclassChildren)!
            children += randomCollection
            currentMirror = currentMirror.superclassMirror()!
        }

        let size = children.count
        var index = 0
        
        for (optionalPropertyName, value) in children {
            
            let propertyName = optionalPropertyName!
            let property = Mirror(reflecting: value)
            
            var handledValue = String()
            if value is Int || value is Double || value is Float || value is Bool {
                handledValue = String(value ?? "null")
            }
            else if let array = value as? [Int?] {
                handledValue += "["
                for (index, value) in array.enumerate() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [Double?] {
                handledValue += "["
                for (index, value) in array.enumerate() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [Float?] {
                handledValue += "["
                for (index, value) in array.enumerate() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [Bool?] {
                handledValue += "["
                for (index, value) in array.enumerate() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [String?] {
                handledValue += "["
                for (index, value) in array.enumerate() {
                    handledValue += value != nil ? "\"\(value!)\"" : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [String] {
                handledValue += "["
                for (index, value) in array.enumerate() {
                    handledValue += "\"\(value)\""
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? NSArray {
                handledValue += "["
                for (index, value) in array.enumerate() {
                    handledValue += "\(value)"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if property.displayStyle == Mirror.DisplayStyle.Class {
                handledValue = toJson(value)
            }
            else if property.displayStyle == Mirror.DisplayStyle.Optional {
                let str = String(value)
                if str != "nil" {
                    handledValue = String(str).substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(9), end: str.endIndex.advancedBy(-1)))
                }
                else {
                    handledValue = "null"
                }
            }
            else {
                handledValue = String(value) != "nil" ? "\"\(value)\"" : "null"
            }
            
            json += "\"\(propertyName)\": \(handledValue)" + (index < size-1 ? ", " : "")
            ++index
        }
        json += "}"
        return json
    }
}