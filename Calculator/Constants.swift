//
//  Constants.swift
//  Calculator
//
//  Created by Bogdan Pintilei on 3/13/17.
//  Copyright © 2017 Bogdan Pintilei. All rights reserved.
//

import Foundation

struct Constants {
    struct Math {
        static let numberOfDigitsAfterDecimalPoint = 6
        static let variableName = "M"
    }
    
    struct Drawing {
        static let pointsPerUnits = 40.0
    }
    
    struct Error {
        static let data = "Calculator: DataSource wasn't found"
        static let partialResult = "Calculator: trying to draw a partial result"
    }
}

