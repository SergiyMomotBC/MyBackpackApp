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
    private var currentClass: Class
    private var lectures: [Lecture]
    private var contentObjects: [[Content]]
    
    var classTitle: String {
        return currentClass.name!
    }
    
    var lecturesCount: Int {
        return self.lectures.count
    }
    
    init(forClass classObject: Class) {
        self.currentClass = classObject
        self.contentObjects = [[Content]]()
        self.lectures = []
        refresh()
    }
    
    func refresh() {
        self.lectures = currentClass.lectures?.allObjects as! [Lecture]
        self.lectures.sort { return $0.date! as Date > $1.date! as Date }
        self.contentObjects.removeAll(keepingCapacity: true)
        
        for lecture in lectures {
            let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "lecture.countID == %d", lecture.countID)
            fetchRequest.fetchBatchSize = 12
            
            contentObjects.append(try! CoreDataManager.shared.managedContext.fetch(fetchRequest) as [Content])
        }
    }
    
    func remove(atIndexPath indexPath: IndexPath) {
        let content = contentObjects[indexPath.section][indexPath.row]
        
        lectures[indexPath.section].removeFromContents(content)
        
        if lectures[indexPath.section].contents?.count == 0 {
            currentClass.removeFromLectures(lectures[indexPath.section])
            lectures.remove(at: indexPath.section)
        }
        
        CoreDataManager.shared.managedContext.delete(content)
        try! FileManager.default.removeItem(at: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL!))
        CoreDataManager.shared.saveContext()
    }
    
    func content(forIndexPath indexPath: IndexPath) -> Content? {
        return contentObjects[indexPath.section][indexPath.row]
    }
    
    func lecture(forSection section: Int) -> Lecture? {
        return self.lectures[section]
    }
}
