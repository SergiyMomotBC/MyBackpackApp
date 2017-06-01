//
//  Reminder+CoreDataProperties.swift
//  My Backpack
//
//  Created by Sergiy Momot on 6/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var remark: String?
    @NSManaged public var title: String?
    @NSManaged public var typeID: Int16
    @NSManaged public var shouldNotify: Bool
    @NSManaged public var inClass: Class?

}
