//
//  JSONSerializer.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

//This is an ongoing effort by me which has been posted in various versions on github as gists and or questions on forums like stackoverflow etc.

import Foundation

public class JSONSerializer {
    
    public static func toJson(object: Any) -> String {
        var json = "{"
        let mirror = Mirror(reflecting: object)
        let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children)!
        let size = mirror.children.count
        
        var index = 0
        for (optionalPropertyName, value) in mirrorChildrenCollection {
            
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
                    handledValue = String(str).substringWithRange(Range<String.Index>(start: advance(str.startIndex, 9), end: advance(str.endIndex, -1)))
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