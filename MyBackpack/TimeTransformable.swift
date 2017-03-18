//
//  TimeTransformable.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/18/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation

public class TimeTransformable: ValueTransformer 
{
    let hour: Int
    let minute: Int
    
    init(hour: Int, minute: Int) { 
        self.hour = hour
        self.minute = minute
    }
    
    override public class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let number = value as? Int else {
            return nil
        }
        
        return TimeTransformable(hour: number / 60, minute: number % 60) 
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        return NSNumber(integerLiteral: hour * 60 + minute)
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
}
