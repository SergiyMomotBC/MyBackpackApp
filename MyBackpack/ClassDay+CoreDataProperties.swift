//
//  ClassDay+CoreDataProperties.swift
//  My Backpack
//
//  Created by Sergiy Momot on 6/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData


extension ClassDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClassDay> {
        return NSFetchRequest<ClassDay>(entityName: "ClassDay")
    }

    @NSManaged public var day: Int16
    @NSManaged public var endTime: Int16
    @NSManaged public var startTime: Int16
    @NSManaged public var forClass: Class

}
