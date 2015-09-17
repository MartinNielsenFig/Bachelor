//
//  StringExtractor.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 03/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class StringExtractor {
    
    static func highestNumberInString (aString: String) -> Int {
        var alphanumerics = String()
        var highest = Int()
        
        func determineHighest() {
            if let number = Int(alphanumerics) {
                if number > highest {
                    highest = number
                }
            }
            alphanumerics = String()
        }
        
        for c in aString.characters {
            if c >= "0" && c <= "9" {
                alphanumerics += String(c)
            }
            else {
                determineHighest()
            }
        }
        
        determineHighest()
        return highest
    }
}