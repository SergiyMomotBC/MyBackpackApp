//
//  ContentDataSource.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData

class ContentDataSource
{
    let currentClass: Class
    private var lectures: [Lecture]
    private var contentObjects: [[Content]]
    
    var classTitle: String {
        return currentClass.name!
    }
    
    var lecturesCount: Int {
        return self.lectures.count
    }
    
    init(forClassWithID classID: NSManagedObjectID) {
        self.currentClass = try! CoreDataManager.shared.managedContext.existingObject(with: classID) as! Class
        self.lectures = currentClass.lectures?.allObjects as! [Lecture]
        self.lectures.sort { return $0.date! as Date > $1.date! as Date }
        self.contentObjects = [[]]
        
        for lecture in lectures {
            let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "lecture.countID == %@", lecture.countID)
            fetchRequest.fetchBatchSize = 12
            
            contentObjects.append(try! CoreDataManager.shared.managedContext.fetch(fetchRequest) as [Content])
        }
    }
    
    func content(forIndexPath indexPath: IndexPath) -> Content? {
        return contentObjects[indexPath.section][indexPath.row]
    }
    
    func lecture(forSection section: Int) -> Lecture? {
        return self.lectures[section]
    }
}
