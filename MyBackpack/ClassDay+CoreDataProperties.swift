//
//  ClassDay+CoreDataProperties.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/18/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData


extension ClassDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClassDay> {
        return NSFetchRequest<ClassDay>(entityName: "ClassDay");
    }

    @NSManaged public var day: String?
    @NSManaged public var endTime: TimeTransformable?
    @NSManaged public var startTime: TimeTransformable?
}
