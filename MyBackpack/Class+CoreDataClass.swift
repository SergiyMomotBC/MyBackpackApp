//
//  Class+CoreDataClass.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData

@objc(Class)
public class Class: NSManagedObject 
{
    static func retrieveLecturesList(forClass object: Class?) -> [String] {
        guard let currClass = object else {
            return []
        }
        
        var lectureNames: [String] = []
        
        var lectureIntervals: [Int] = []
        
        let days = (currClass.days?.map { ($0 as! ClassDay).day } ?? []).sorted()
        
        for i in 1..<days.count {
            lectureIntervals.append(Int(days[i] - days[i - 1]))
        }
        
        lectureIntervals.append(Int(7 - days.last!) + Int(days.first!))
        
        let dayOfWeek = Calendar.current.dateComponents([.weekday], from: currClass.firstLectureDate! as Date).weekday!
        
        let firstDay = days.index(of: Int16(dayOfWeek))!
        
        for _ in 0..<firstDay {
            lectureIntervals.append(lectureIntervals.removeFirst())
        }
        
        var currentDate = currClass.firstLectureDate! as Date
        let todayDate = Date()
        var lecturesCount = 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        while currentDate < todayDate {
            lectureNames.insert("Lecture \(lecturesCount) - \(dateFormatter.string(from: currentDate))", at: 0)
            currentDate = currentDate.addingTimeInterval(TimeInterval(3600 * 24 * lectureIntervals.first!))
            lectureIntervals.append(lectureIntervals.removeFirst())
            lecturesCount += 1
        }
        
        return lectureNames
    }
}
