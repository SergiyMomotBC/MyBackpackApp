//
//  ClassDay+CoreDataProperties.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData


extension ClassDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClassDay> {
        return NSFetchRequest<ClassDay>(entityName: "ClassDay");
    }

    @NSManaged public var day: String?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var endTime: NSDate?

}
