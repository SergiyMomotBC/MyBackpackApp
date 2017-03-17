//
//  Class+CoreDataProperties.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData


extension Class {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Class> {
        return NSFetchRequest<Class>(entityName: "Class");
    }

    @NSManaged public var name: String?
    @NSManaged public var firstLectureDate: NSDate?
    @NSManaged public var lastLectureDate: NSDate?
    @NSManaged public var lectures: NSSet?
    @NSManaged public var days: NSSet?

}

// MARK: Generated accessors for lectures
extension Class {

    @objc(addLecturesObject:)
    @NSManaged public func addToLectures(_ value: Lecture)

    @objc(removeLecturesObject:)
    @NSManaged public func removeFromLectures(_ value: Lecture)

    @objc(addLectures:)
    @NSManaged public func addToLectures(_ values: NSSet)

    @objc(removeLectures:)
    @NSManaged public func removeFromLectures(_ values: NSSet)

}

// MARK: Generated accessors for days
extension Class {

    @objc(addDaysObject:)
    @NSManaged public func addToDays(_ value: ClassDay)

    @objc(removeDaysObject:)
    @NSManaged public func removeFromDays(_ value: ClassDay)

    @objc(addDays:)
    @NSManaged public func addToDays(_ values: NSSet)

    @objc(removeDays:)
    @NSManaged public func removeFromDays(_ values: NSSet)

}
