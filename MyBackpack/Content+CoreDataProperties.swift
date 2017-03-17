//
//  Content+CoreDataProperties.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData


extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content");
    }

    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var resourceURL: String?
    @NSManaged public var title: String?
    @NSManaged public var typeID: Int16
    @NSManaged public var lecture: Lecture?

}
